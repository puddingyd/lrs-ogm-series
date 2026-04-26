#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# download_grch38_analysis_set.sh
#
# Downloads GRCh38_full_analysis_set_plus_decoy_hla.fa (+ .fai) from the
# 1000 Genomes FTP to a local, writable directory. This is the reference the
# Case 2 WES BAM was aligned against (hs38d1 decoys + chrEBV + HLA contigs).
#
# After running, update REF in run_manta_case2.sh to the path printed at the
# end and re-run the Manta wrapper.
# ----------------------------------------------------------------------------

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: failed at line $LINENO (exit $rc): $BASH_COMMAND" >&2; exit $rc' ERR

# Where to put the new reference. Local SSD recommended (network mount = slow).
REF_DIR="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta/ref"
BAM="/Users/changym/Desktop/LR_WGS/Case2/WES/AA001181/AA001181.bam"

REF_URL_BASE="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome"
REF_FA="GRCh38_full_analysis_set_plus_decoy_hla.fa"
REF_FAI="${REF_FA}.fai"

mkdir -p "$REF_DIR"
cd "$REF_DIR"

echo "==> Free space check (need ~3.5 GB)"
df -h "$REF_DIR" | awk 'NR==1 || /\//'

if [[ -s "$REF_FA" && -s "$REF_FAI" ]]; then
    echo "==> Reference already present, skipping download:"
    ls -lh "$REF_FA" "$REF_FAI"
else
    echo "==> Downloading $REF_FA (~3.0 GB) -- this can take 10-30 min"
    curl -fL --retry 4 --retry-delay 10 -o "$REF_FA"  "${REF_URL_BASE}/${REF_FA}"
    echo "==> Downloading $REF_FAI"
    curl -fL --retry 4 --retry-delay 10 -o "$REF_FAI" "${REF_URL_BASE}/${REF_FAI}"
fi

echo "==> Verifying .fai matches FASTA"
samtools faidx "$REF_FA" chr7:69938000-69939000 >/dev/null 2>&1 \
    || { echo "ERROR: samtools cannot read $REF_FA"; exit 1; }

echo "==> Verifying every BAM @SQ exists in the new reference"
BAM_CONTIGS=$(samtools view -H "$BAM" | awk '/^@SQ/{for(i=1;i<=NF;i++)if($i~/^SN:/){sub("SN:","",$i);print $i}}' | sort)
REF_CONTIGS=$(awk '{print $1}' "${REF_FA}.fai" | sort)
MISSING=$(comm -23 <(echo "$BAM_CONTIGS") <(echo "$REF_CONTIGS") || true)
if [[ -n "$MISSING" ]]; then
    echo "ERROR: BAM still has contigs not in the new reference:" >&2
    echo "$MISSING" | head -10 >&2
    exit 1
fi
echo "    OK -- all $(echo "$BAM_CONTIGS" | wc -l | tr -d ' ') BAM contigs are present in reference."

echo
echo "==> DONE. Update run_manta_case2.sh:"
echo "      REF=\"$REF_DIR/$REF_FA\""
