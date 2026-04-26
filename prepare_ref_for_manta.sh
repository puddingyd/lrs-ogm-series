#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# prepare_ref_for_manta.sh
#
# Build a Manta-compatible reference by appending any extra contigs (commonly
# chrEBV) from the BAM header onto a copy of your existing hg38 FASTA.
#
# We do NOT modify the original reference under /Volumes/genetics (which may
# be shared / read-only). Output goes to a writable directory you choose.
# ----------------------------------------------------------------------------

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: failed at line $LINENO (exit $rc): $BASH_COMMAND" >&2; exit $rc' ERR

# ============================================================================
# CONFIG
# ============================================================================
BAM="/Users/changym/Desktop/LR_WGS/Case2/WES/AA001181/AA001181.bam"
REF_IN="/Volumes/genetics/humandb/hg38/hg38.fa"

# Output reference (writable). The Manta wrapper will point to this file.
REF_OUT_DIR="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta/ref"
REF_OUT="${REF_OUT_DIR}/hg38_with_ebv.fa"

# ============================================================================

mkdir -p "$REF_OUT_DIR"
cd "$REF_OUT_DIR"

echo "==> Listing contigs in BAM and REF"
samtools view -H "$BAM" \
  | awk '/^@SQ/{for(i=1;i<=NF;i++)if($i~/^SN:/){sub("SN:","",$i);print $i}}' \
  | sort > bam_contigs.txt
awk '{print $1}' "${REF_IN}.fai" | sort > ref_contigs.txt

MISSING=$(comm -23 bam_contigs.txt ref_contigs.txt)
echo "    BAM has $(wc -l < bam_contigs.txt) contigs; REF has $(wc -l < ref_contigs.txt)"
if [[ -z "$MISSING" ]]; then
    echo "    No contigs missing from REF -- you don't need this script. Exiting."
    exit 0
fi
echo "    Contigs in BAM but NOT in REF:"
echo "$MISSING" | sed 's/^/      /'

# ============================================================================
# Decide what to do
# ============================================================================
# We can auto-fetch chrEBV (NC_007605.1) from NCBI. Anything else missing
# (HLA-*, chrUn_*_decoy, etc.) means the BAM was aligned to a full analysis
# set; the user must download that reference manually instead.

OTHERS=$(echo "$MISSING" | grep -v -x 'chrEBV' || true)
if [[ -n "$OTHERS" ]]; then
    echo
    echo "ERROR: BAM is missing more than just chrEBV. Auto-fix not safe." >&2
    echo "These contigs (decoys / HLA / alt scaffolds) need a matching reference:" >&2
    echo "$OTHERS" | sed 's/^/  /' >&2
    echo >&2
    echo "Recommended: download the BWA-MEM-compatible GRCh38 analysis set:" >&2
    echo "  https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSV/working/HGSVC2/refs/hg38/GRCh38_full_analysis_set_plus_decoy_hla.fa" >&2
    echo "  (also available from NCBI: GCA_000001405.15_GRCh38_full_analysis_set.fna)" >&2
    echo "Then point REF in run_manta_case2.sh at that file and re-index with samtools faidx." >&2
    exit 1
fi

# ============================================================================
# Build hg38_with_ebv.fa = copy of hg38.fa + chrEBV appended
# ============================================================================
echo "==> Fetching chrEBV (NC_007605.1) from NCBI"
curl -fsSL \
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_007605.1&rettype=fasta&retmode=text' \
    -o NC_007605.1.fa
EBV_LEN=$(awk '/^>/{next}{l+=length($0)}END{print l}' NC_007605.1.fa)
echo "    chrEBV downloaded: ${EBV_LEN} bp"
if [[ "$EBV_LEN" -lt 170000 || "$EBV_LEN" -gt 175000 ]]; then
    echo "ERROR: unexpected chrEBV length ($EBV_LEN); expected ~171823 bp" >&2
    exit 1
fi
# Rewrite the header so it's literally ">chrEBV" (matches BAM header)
awk 'BEGIN{p=0} /^>/{print ">chrEBV"; p=1; next} p{print}' NC_007605.1.fa > chrEBV.fa

echo "==> Building extended reference: $REF_OUT"
# Copy via cat to keep cross-volume compatibility (avoid `cp` on network mount)
cat "$REF_IN" chrEBV.fa > "$REF_OUT"

echo "==> Indexing extended reference"
samtools faidx "$REF_OUT"

echo "==> Verifying"
NEW_CONTIGS=$(awk '{print $1}' "${REF_OUT}.fai" | sort)
if ! diff <(echo "$NEW_CONTIGS") <(sort -u <(cat ref_contigs.txt; echo chrEBV)) >/dev/null; then
    echo "WARNING: extended reference contigs do not exactly match expectation."
fi
grep -P '^chrEBV\t' "${REF_OUT}.fai"

echo
echo "==> DONE."
echo "    Update run_manta_case2.sh:"
echo "      REF=\"$REF_OUT\""
