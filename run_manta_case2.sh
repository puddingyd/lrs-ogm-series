#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# run_manta_case2.sh
#
# Re-analyze Case 2 WES BAM with Manta to test whether the AUTS2-disrupting
# inversion (chr7:69,938,691 <-> chr7:95,720,897) can be retrospectively
# recovered from short-read exome data.
#
# Platform : macOS (Apple Silicon or Intel) - runs Manta inside Docker
# Requires : Docker Desktop, samtools, bcftools (brew install samtools bcftools)
# Manta    : github.com/Illumina/manta  (we use the official quay.io image)
# ----------------------------------------------------------------------------

set -euo pipefail

# ============================================================================
# 1. USER CONFIG  -- 請依實際路徑修改
# ============================================================================

# Input BAM (sorted, indexed, aligned to the same reference as $REF below)
BAM="/ABSOLUTE/PATH/TO/case2.wes.bam"

# Reference FASTA + .fai (must match the BAM build; Case 2 LRS used GRCh38)
REF="/ABSOLUTE/PATH/TO/GRCh38.fa"

# Exome capture target BED (the kit's bait/target intervals).
# Must be bgzipped + tabix-indexed for Manta's --callRegions.
# If you only have a plain BED:
#   sort -k1,1 -k2,2n targets.bed | bgzip > targets.bed.gz && tabix -p bed targets.bed.gz
TARGETS_BED_GZ="/ABSOLUTE/PATH/TO/exome_targets.bed.gz"

# Output directory (will be created)
OUTDIR="$(pwd)/manta_case2_out"

# How many CPU threads Manta may use
THREADS=8

# Manta Docker image (pinned for reproducibility)
MANTA_IMAGE="quay.io/biocontainers/manta:1.6.0--h9ee0642_1"

# Region of interest for post-hoc filtering (Case 2 inversion breakpoints
# from LRS: chr7:69,938,691 and chr7:95,720,897). +/- 50 kb window.
ROI_CHR="chr7"
ROI_LEFT_START=69888691
ROI_LEFT_END=69988691
ROI_RIGHT_START=95670897
ROI_RIGHT_END=95770897

# ============================================================================
# 2. SANITY CHECKS
# ============================================================================

echo "==> Checking dependencies"
for cmd in docker samtools bcftools; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: '$cmd' not found in PATH. Install via: brew install $cmd  (or Docker Desktop)" >&2
        exit 1
    fi
done

echo "==> Checking input files"
[[ -f "$BAM"    ]] || { echo "ERROR: BAM not found: $BAM" >&2; exit 1; }
[[ -f "$REF"    ]] || { echo "ERROR: REF not found: $REF" >&2; exit 1; }
[[ -f "${REF}.fai" ]] || { echo "ERROR: missing ${REF}.fai (run: samtools faidx $REF)" >&2; exit 1; }
[[ -f "$TARGETS_BED_GZ" ]] || { echo "ERROR: targets BED not found: $TARGETS_BED_GZ" >&2; exit 1; }
[[ -f "${TARGETS_BED_GZ}.tbi" ]] || { echo "ERROR: missing ${TARGETS_BED_GZ}.tbi (run: tabix -p bed $TARGETS_BED_GZ)" >&2; exit 1; }

# Make sure BAM is indexed
if [[ ! -f "${BAM}.bai" && ! -f "${BAM%.bam}.bai" ]]; then
    echo "==> BAM index missing, creating with samtools"
    samtools index -@ "$THREADS" "$BAM"
fi

# Confirm BAM contig style matches reference (chr1 vs 1)
BAM_CHR=$(samtools view -H "$BAM" | awk '/^@SQ/{print $2; exit}' | sed 's/SN://')
REF_CHR=$(head -n1 "${REF}.fai" | cut -f1)
if [[ "$BAM_CHR" != "$REF_CHR" ]]; then
    echo "WARNING: BAM first contig ($BAM_CHR) != reference first contig ($REF_CHR)."
    echo "         Manta will likely fail. Re-align or re-header before continuing."
fi

mkdir -p "$OUTDIR"

# ============================================================================
# 3. RESOLVE PATHS FOR DOCKER BIND-MOUNTS
# ============================================================================
# Manta inside the container needs to see all input files. We mount each
# file's parent directory and rewrite paths to /data/<basename>.

abspath() { python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"; }

BAM_ABS=$(abspath "$BAM");                BAM_DIR=$(dirname "$BAM_ABS")
REF_ABS=$(abspath "$REF");                REF_DIR=$(dirname "$REF_ABS")
TGT_ABS=$(abspath "$TARGETS_BED_GZ");     TGT_DIR=$(dirname "$TGT_ABS")
OUT_ABS=$(abspath "$OUTDIR")

DOCKER_RUN=(
    docker run --rm
    --platform linux/amd64                 # force amd64 image on Apple Silicon
    -v "$BAM_DIR":/in_bam:ro
    -v "$REF_DIR":/in_ref:ro
    -v "$TGT_DIR":/in_tgt:ro
    -v "$OUT_ABS":/out
    "$MANTA_IMAGE"
)

C_BAM="/in_bam/$(basename "$BAM_ABS")"
C_REF="/in_ref/$(basename "$REF_ABS")"
C_TGT="/in_tgt/$(basename "$TGT_ABS")"
C_RUN="/out/manta_run"

# ============================================================================
# 4. CONFIGURE + RUN MANTA  (--exome enables WES-tuned thresholds)
# ============================================================================

echo "==> configManta.py"
"${DOCKER_RUN[@]}" configManta.py \
    --bam "$C_BAM" \
    --referenceFasta "$C_REF" \
    --runDir "$C_RUN" \
    --exome \
    --callRegions "$C_TGT"

echo "==> runWorkflow.py (this can take 10-60 min for a typical exome)"
"${DOCKER_RUN[@]}" "$C_RUN/runWorkflow.py" -j "$THREADS"

# ============================================================================
# 5. COLLECT OUTPUT VCFs
# ============================================================================

VCF_DIAG="$OUTDIR/manta_run/results/variants/diploidSV.vcf.gz"
VCF_CAND="$OUTDIR/manta_run/results/variants/candidateSV.vcf.gz"
VCF_SMALL="$OUTDIR/manta_run/results/variants/candidateSmallIndels.vcf.gz"

echo "==> Manta finished. Output VCFs:"
ls -lh "$OUTDIR/manta_run/results/variants/"

# ============================================================================
# 6. POST-HOC: extract anything overlapping the AUTS2 / 7q21.3 breakpoint area
# ============================================================================

echo "==> Filtering for SVs near the Case 2 inversion breakpoints"

LEFT_REGION="${ROI_CHR}:${ROI_LEFT_START}-${ROI_LEFT_END}"
RIGHT_REGION="${ROI_CHR}:${ROI_RIGHT_START}-${ROI_RIGHT_END}"

for VCF in "$VCF_DIAG" "$VCF_CAND"; do
    [[ -f "$VCF" ]] || continue
    TAG=$(basename "$VCF" .vcf.gz)
    OUT_TSV="$OUTDIR/${TAG}.AUTS2_region.tsv"

    {
        echo -e "CHROM\tPOS\tID\tSVTYPE\tEND\tMATEID\tFILTER\tALT"
        bcftools view -r "${LEFT_REGION},${RIGHT_REGION}" "$VCF" 2>/dev/null \
          | bcftools query -f '%CHROM\t%POS\t%ID\t%INFO/SVTYPE\t%INFO/END\t%INFO/MATEID\t%FILTER\t%ALT\n'
    } > "$OUT_TSV"

    N=$(($(wc -l < "$OUT_TSV") - 1))
    echo "    $TAG : $N call(s) near chr7:69.9 Mb / chr7:95.7 Mb  ->  $OUT_TSV"

    # Highlight any record whose ALT references the partner breakpoint
    # (Manta encodes inversions as paired BNDs)
    echo "    -- BND mate-pair check (calls whose ALT mentions the partner region):"
    bcftools view -r "$LEFT_REGION" "$VCF" 2>/dev/null \
      | awk -v rmin="$ROI_RIGHT_START" -v rmax="$ROI_RIGHT_END" '
            !/^#/ && $5 ~ /chr7:/ {
                match($5, /chr7:([0-9]+)/, m);
                if (m[1]+0 >= rmin && m[1]+0 <= rmax)
                    print "      HIT  " $1":"$2"  ALT="$5"  ID="$3
            }'
done

echo
echo "==> DONE."
echo "   Primary VCF      : $VCF_DIAG"
echo "   Candidate VCF    : $VCF_CAND"
echo "   ROI-filtered TSV : $OUTDIR/*.AUTS2_region.tsv"
echo
echo "Tip: open the candidateSV VCF too -- WES coverage at intronic breakpoints"
echo "     is sparse, so a real BND may appear only in candidateSV (not diploidSV)."
