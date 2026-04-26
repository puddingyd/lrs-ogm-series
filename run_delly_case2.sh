#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# run_delly_case2.sh
#
# Independent short-read SV calling on the Case 2 WES BAM with Delly, to
# corroborate the Manta negative finding ("regardless of caller").
#
# Platform : macOS (Apple Silicon or Intel) - runs Delly inside Docker
# Requires : Docker Desktop, samtools, bcftools
# Delly    : github.com/dellytools/delly
# ----------------------------------------------------------------------------

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: failed at line $LINENO (exit $rc): $BASH_COMMAND" >&2; exit $rc' ERR

# ============================================================================
# 1. CONFIG  -- 已填好 Case 2 路徑
# ============================================================================
BAM="/Users/changym/Desktop/LR_WGS/Case2/WES/AA001181/AA001181.bam"
REF="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa"
OUTDIR="/Users/changym/Desktop/LR_WGS/Case2/WES/Delly"

# Pinned Delly version (official image).
DELLY_IMAGE="dellytools/delly:v1.2.6"

# Optional exclude regions (Delly ships an hg38 exclude list; leave empty to
# skip). Recommended for WGS, mostly cosmetic for WES.
EXCLUDE_BED=""

# ROI: ±50 kb around each LRS-defined breakpoint
ROI_CHR="chr7"
ROI_LEFT_START=69888691
ROI_LEFT_END=69988691
ROI_RIGHT_START=95670897
ROI_RIGHT_END=95770897

THREADS=8
SAMPLE="case2"

# ============================================================================
# 2. SANITY CHECKS
# ============================================================================
echo "==> Checking dependencies"
for cmd in docker samtools bcftools python3; do
    command -v "$cmd" >/dev/null || { echo "ERROR: $cmd missing" >&2; exit 1; }
done

echo "==> Checking Docker daemon"
docker info >/dev/null 2>&1 || { echo "ERROR: Docker not running" >&2; exit 1; }

echo "==> Checking input files"
[[ -f "$BAM" ]]        || { echo "ERROR: BAM missing: $BAM" >&2; exit 1; }
[[ -f "$REF" ]]        || { echo "ERROR: REF missing: $REF" >&2; exit 1; }
[[ -f "${REF}.fai" ]]  || { echo "ERROR: REF .fai missing -- run samtools faidx" >&2; exit 1; }
if [[ ! -f "${BAM}.bai" && ! -f "${BAM%.bam}.bai" ]]; then
    echo "==> Creating BAM index"
    samtools index -@ "$THREADS" "$BAM"
fi

mkdir -p "$OUTDIR"

# ============================================================================
# 3. RESOLVE PATHS FOR DOCKER MOUNTS
# ============================================================================
abspath() { python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"; }

BAM_ABS=$(abspath "$BAM");   BAM_DIR=$(dirname "$BAM_ABS")
REF_ABS=$(abspath "$REF");   REF_DIR=$(dirname "$REF_ABS")
OUT_ABS=$(abspath "$OUTDIR")

DOCKER_BASE=(
    docker run --rm
    --platform linux/amd64
    -v "$BAM_DIR":/in_bam:ro
    -v "$REF_DIR":/in_ref:ro
    -v "$OUT_ABS":/out
)

if [[ -n "$EXCLUDE_BED" ]]; then
    [[ -f "$EXCLUDE_BED" ]] || { echo "ERROR: EXCLUDE_BED missing" >&2; exit 1; }
    EXC_ABS=$(abspath "$EXCLUDE_BED");   EXC_DIR=$(dirname "$EXC_ABS")
    DOCKER_BASE+=( -v "$EXC_DIR":/in_exc:ro )
    EXC_PATH="/in_exc/$(basename "$EXC_ABS")"
else
    EXC_PATH=""
fi

C_BAM="/in_bam/$(basename "$BAM_ABS")"
C_REF="/in_ref/$(basename "$REF_ABS")"

# ============================================================================
# 4. RUN DELLY (calls all SV types: DEL, DUP, INV, INS, BND)
# ============================================================================
BCF_OUT="$OUTDIR/${SAMPLE}.delly.bcf"
VCF_OUT="$OUTDIR/${SAMPLE}.delly.vcf.gz"

echo "==> Pulling Delly image: $DELLY_IMAGE"
docker pull --platform linux/amd64 "$DELLY_IMAGE"

# Build the delly command incrementally so we never expand a possibly-empty
# array under `set -u` (bash 3.2 on macOS treats that as unbound variable).
DELLY_CMD=( delly call -g "$C_REF" -o "/out/$(basename "$BCF_OUT")" )
[[ -n "$EXC_PATH" ]] && DELLY_CMD+=( -x "$EXC_PATH" )
DELLY_CMD+=( "$C_BAM" )

echo "==> Running delly call (this can take 5-30 min on WES)"
"${DOCKER_BASE[@]}" \
    -e OMP_NUM_THREADS="$THREADS" \
    "$DELLY_IMAGE" \
    "${DELLY_CMD[@]}"

echo "==> Converting BCF to VCF.gz"
bcftools view -O z -o "$VCF_OUT" "$BCF_OUT"
bcftools index -t "$VCF_OUT"

echo "==> Delly output:"
ls -lh "$BCF_OUT" "$VCF_OUT"
TOTAL=$(bcftools view -H "$VCF_OUT" | wc -l | tr -d ' ')
echo "    Total Delly SV records: $TOTAL"
echo "    By chromosome:"
bcftools view -H "$VCF_OUT" | awk '{print $1}' | sort | uniq -c | head -30

# ============================================================================
# 5. POST-HOC: ROI extraction + bidirectional BND mate-pair check
# ============================================================================
LEFT_REGION="${ROI_CHR}:${ROI_LEFT_START}-${ROI_LEFT_END}"
RIGHT_REGION="${ROI_CHR}:${ROI_RIGHT_START}-${ROI_RIGHT_END}"

OUT_TSV="$OUTDIR/${SAMPLE}.delly.AUTS2_region.tsv"
{
    echo -e "CHROM\tPOS\tID\tSVTYPE\tEND\tCHR2\tFILTER\tALT"
    bcftools view -r "${LEFT_REGION},${RIGHT_REGION}" "$VCF_OUT" 2>/dev/null \
      | bcftools query -f '%CHROM\t%POS\t%ID\t%INFO/SVTYPE\t%INFO/END\t%INFO/CHR2\t%FILTER\t%ALT\n' \
      || true
} > "$OUT_TSV"

N=$(($(wc -l < "$OUT_TSV") - 1))
echo
echo "==> ROI summary"
echo "    $N record(s) within either ±50 kb breakpoint window  ->  $OUT_TSV"
[[ "$N" -gt 0 ]] && awk -F'\t' 'NR>1{print "      "$3"  SVTYPE="$4"  FILTER="$7}' "$OUT_TSV"

bnd_check() {
    local search_region=$1 partner_min=$2 partner_max=$3 label=$4
    # Delly encodes BND in INFO/CHR2 + INFO/END (not in ALT) for translocations,
    # and as INV/DEL/DUP records with own POS+END for intra-chromosomal.
    bcftools view -r "$search_region" "$VCF_OUT" 2>/dev/null \
      | bcftools query -f '%CHROM\t%POS\t%ID\t%INFO/SVTYPE\t%INFO/END\t%INFO/CHR2\t%FILTER\t%ALT\n' \
      | awk -F'\t' -v rmin="$partner_min" -v rmax="$partner_max" -v lbl="$label" '
            {
                # Check INFO/END for partner coordinate
                if ($5+0 >= rmin && $5+0 <= rmax) {
                    print "      HIT [" lbl " - END]  " $1":"$2"-"$5"  SVTYPE="$4"  FILTER="$7"  ID="$3
                    next
                }
                # Also scan ALT for chr*:NNNN (BND notation)
                s = $8
                while (match(s, /chr[0-9XYM]+:[0-9]+/)) {
                    coord = substr(s, RSTART, RLENGTH)
                    sub(/^chr[0-9XYM]+:/, "", coord)
                    if (coord+0 >= rmin && coord+0 <= rmax) {
                        print "      HIT [" lbl " - ALT]  " $1":"$2"  SVTYPE="$4"  FILTER="$7"  ALT="$8"  ID="$3
                        break
                    }
                    s = substr(s, RSTART + RLENGTH)
                }
            }' || true
}

echo "    -- Mate-pair scan (records where the partner end falls in the other ROI):"
bnd_check "$LEFT_REGION"  "$ROI_RIGHT_START" "$ROI_RIGHT_END" "L->R"
bnd_check "$RIGHT_REGION" "$ROI_LEFT_START"  "$ROI_LEFT_END"  "R->L"

echo
echo "==> DONE."
echo "   Delly VCF        : $VCF_OUT"
echo "   ROI-filtered TSV : $OUT_TSV"
