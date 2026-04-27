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

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: failed at line $LINENO (exit $rc): $BASH_COMMAND" >&2; exit $rc' ERR

# ============================================================================
# 1. USER CONFIG  -- 請依實際路徑修改
# ============================================================================

# Input BAM (sorted, indexed, aligned to the same reference as $REF below)
BAM="/Users/changym/Desktop/LR_WGS/Case2/WES/AA001181/AA001181.bam"

# Reference FASTA + .fai (must match the BAM build; Case 2 LRS used GRCh38)
REF="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa"

# OPTIONAL exome capture target BED (Roche KAPA HyperExome).
# Leave EMPTY ("") to skip --callRegions (recommended for finding the
# AUTS2 intron 2 BND, which lies OUTSIDE capture targets and only shows
# up via off-target / spill-over reads).
#
# If you want to use one, it must be bgzipped + tabix-indexed:
#   sort -k1,1 -k2,2n targets.bed | bgzip > targets.bed.gz && tabix -p bed targets.bed.gz
# Public V1 BED (close superset of V2/Plus in coding regions, no login required):
#   curl -O https://hgdownload.soe.ucsc.edu/gbdb/hg38/exomeProbesets/KAPA_HyperExome_hg38_capture_targets.bb
#   bigBedToBed KAPA_HyperExome_hg38_capture_targets.bb /tmp/k.bed
#   sort -k1,1 -k2,2n /tmp/k.bed | bgzip > KAPA_HyperExome_hg38_capture_targets.bed.gz
#   tabix -p bed KAPA_HyperExome_hg38_capture_targets.bed.gz
# For the official V2/Plus BED, login to sequencing.roche.com -> eLabDoc.
TARGETS_BED_GZ=""

# Output directory (will be created)
OUTDIR="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta"

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
for cmd in docker samtools bcftools python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: '$cmd' not found in PATH. Install via: brew install $cmd  (or Docker Desktop)" >&2
        exit 1
    fi
done

echo "==> Checking that Docker daemon is running"
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon not running. Start Docker Desktop and re-run." >&2
    exit 1
fi

echo "==> Checking input files"
[[ -f "$BAM"    ]] || { echo "ERROR: BAM not found: $BAM" >&2; exit 1; }
[[ -f "$REF"    ]] || { echo "ERROR: REF not found: $REF" >&2; exit 1; }
[[ -f "${REF}.fai" ]] || { echo "ERROR: missing ${REF}.fai (run: samtools faidx $REF)" >&2; exit 1; }

USE_BED=0
if [[ -n "$TARGETS_BED_GZ" ]]; then
    [[ -f "$TARGETS_BED_GZ" ]] || { echo "ERROR: targets BED not found: $TARGETS_BED_GZ" >&2; exit 1; }
    [[ -f "${TARGETS_BED_GZ}.tbi" ]] || { echo "ERROR: missing ${TARGETS_BED_GZ}.tbi (run: tabix -p bed $TARGETS_BED_GZ)" >&2; exit 1; }
    USE_BED=1
    echo "    Using --callRegions BED: $TARGETS_BED_GZ"
else
    echo "    No --callRegions BED supplied (recommended: lets Manta use off-target evidence)"
fi

# Make sure BAM is indexed
echo "==> Checking BAM index"
if [[ ! -f "${BAM}.bai" && ! -f "${BAM%.bam}.bai" ]]; then
    echo "    BAM index missing, creating with samtools"
    samtools index -@ "$THREADS" "$BAM"
else
    echo "    BAM index found"
fi

# Confirm BAM contig style matches reference (chr1 vs 1).
# Note: awk's early `exit` makes samtools see SIGPIPE; capture stderr separately
# and tolerate the 141 exit code so `set -e` does not kill the script.
echo "==> Checking BAM vs reference contig naming"
BAM_CHR=$(samtools view -H "$BAM" 2>/dev/null | awk '/^@SQ/{sub(/^SN:/,"",$2); print $2; exit}' || true)
REF_CHR=$(awk 'NR==1{print $1}' "${REF}.fai")
echo "    BAM first contig: ${BAM_CHR:-<empty>}"
echo "    REF first contig: ${REF_CHR:-<empty>}"
if [[ -z "$BAM_CHR" || -z "$REF_CHR" ]]; then
    echo "ERROR: could not read contig names from BAM or REF .fai" >&2
    exit 1
fi
if [[ "$BAM_CHR" != "$REF_CHR" ]]; then
    echo "WARNING: contig naming differs (BAM='$BAM_CHR', REF='$REF_CHR')."
    echo "         Manta will likely fail. Re-align or re-header before continuing."
fi

echo "==> Creating output directory: $OUTDIR"
mkdir -p "$OUTDIR"

# ============================================================================
# 3. RESOLVE PATHS FOR DOCKER BIND-MOUNTS
# ============================================================================
# Manta inside the container needs to see all input files. We mount each
# file's parent directory and rewrite paths to /data/<basename>.

echo "==> Resolving absolute paths for Docker bind-mounts"
abspath() { python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"; }

BAM_ABS=$(abspath "$BAM");                BAM_DIR=$(dirname "$BAM_ABS")
REF_ABS=$(abspath "$REF");                REF_DIR=$(dirname "$REF_ABS")
OUT_ABS=$(abspath "$OUTDIR")
echo "    BAM_DIR=$BAM_DIR"
echo "    REF_DIR=$REF_DIR"
echo "    OUT_ABS=$OUT_ABS"

DOCKER_RUN=(
    docker run --rm
    --platform linux/amd64                 # force amd64 image on Apple Silicon
    -v "$BAM_DIR":/in_bam:ro
    -v "$REF_DIR":/in_ref:ro
    -v "$OUT_ABS":/out
    "$MANTA_IMAGE"
)

if [[ $USE_BED -eq 1 ]]; then
    TGT_ABS=$(abspath "$TARGETS_BED_GZ");  TGT_DIR=$(dirname "$TGT_ABS")
    DOCKER_RUN+=( -v "$TGT_DIR":/in_tgt:ro )
    C_TGT="/in_tgt/$(basename "$TGT_ABS")"
fi

C_BAM="/in_bam/$(basename "$BAM_ABS")"
C_REF="/in_ref/$(basename "$REF_ABS")"
C_RUN="/out/manta_run"

# ============================================================================
# 4. CONFIGURE + RUN MANTA  (--exome enables WES-tuned thresholds)
# ============================================================================

CONFIG_ARGS=( --bam "$C_BAM" --referenceFasta "$C_REF" --runDir "$C_RUN" --exome )
[[ $USE_BED -eq 1 ]] && CONFIG_ARGS+=( --callRegions "$C_TGT" )

echo "==> Pulling Manta Docker image (first run only): $MANTA_IMAGE"
docker pull --platform linux/amd64 "$MANTA_IMAGE"

echo "==> configManta.py"
echo "    args: ${CONFIG_ARGS[*]}"
"${DOCKER_RUN[@]}" configManta.py "${CONFIG_ARGS[@]}"

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

# Helper: scan a region's records for ALT fields citing a partner range.
# POSIX awk only (BSD awk on macOS does not support gawk's match(s,re,arr)).
bnd_check() {
    local vcf=$1 search_region=$2 partner_min=$3 partner_max=$4 label=$5
    bcftools view -r "$search_region" "$vcf" 2>/dev/null \
      | awk -v rmin="$partner_min" -v rmax="$partner_max" -v lbl="$label" '
            !/^#/ {
                s = $5
                while (match(s, /chr[0-9XYM]+:[0-9]+/)) {
                    coord = substr(s, RSTART, RLENGTH)
                    sub(/^chr[0-9XYM]+:/, "", coord)
                    if (coord+0 >= rmin && coord+0 <= rmax) {
                        print "      HIT [" lbl "]  " $1":"$2"  ID="$3"  FILTER="$7"  ALT="$5
                        next
                    }
                    s = substr(s, RSTART + RLENGTH)
                }
            }' || true
}

for VCF in "$VCF_DIAG" "$VCF_CAND"; do
    [[ -f "$VCF" ]] || continue
    TAG=$(basename "$VCF" .vcf.gz)
    OUT_TSV="$OUTDIR/${TAG}.AUTS2_region.tsv"

    {
        echo -e "CHROM\tPOS\tID\tSVTYPE\tEND\tMATEID\tFILTER\tALT"
        bcftools view -r "${LEFT_REGION},${RIGHT_REGION}" "$VCF" 2>/dev/null \
          | bcftools query -f '%CHROM\t%POS\t%ID\t%INFO/SVTYPE\t%INFO/END\t%INFO/MATEID\t%FILTER\t%ALT\n' \
          || true
    } > "$OUT_TSV"

    N=$(($(wc -l < "$OUT_TSV") - 1))
    echo "    $TAG : $N record(s) near chr7:69.9 Mb / chr7:95.7 Mb  ->  $OUT_TSV"

    # Show PASS / non-PASS split for the records in ROI
    if [[ "$N" -gt 0 ]]; then
        awk -F'\t' 'NR>1{print "      "$3"  SVTYPE="$4"  FILTER="$7}' "$OUT_TSV"
    fi

    # Bidirectional BND mate-pair check: a real reciprocal inversion will have
    # records on the LEFT side whose ALT cites the RIGHT region, AND vice-versa.
    echo "    -- BND mate-pair check (calls whose ALT references the partner region):"
    bnd_check "$VCF" "$LEFT_REGION"  "$ROI_RIGHT_START" "$ROI_RIGHT_END" "L->R"
    bnd_check "$VCF" "$RIGHT_REGION" "$ROI_LEFT_START"  "$ROI_LEFT_END"  "R->L"
done

echo
echo "==> DONE."
echo "   Primary VCF      : $VCF_DIAG"
echo "   Candidate VCF    : $VCF_CAND"
echo "   ROI-filtered TSV : $OUTDIR/*.AUTS2_region.tsv"
echo
echo "Tip: open the candidateSV VCF too -- WES coverage at intronic breakpoints"
echo "     is sparse, so a real BND may appear only in candidateSV (not diploidSV)."
