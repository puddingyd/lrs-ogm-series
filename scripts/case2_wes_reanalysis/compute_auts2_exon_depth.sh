#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# compute_auts2_exon_depth.sh
#
# Build a per-exon WES read-depth table for Case 2:
#   - all AUTS2 exons (RefSeq NM_015570 from UCSC REST API)
#   - TP53 exon 4 (positive control, ubiquitously captured)
#   - LRS-defined inversion breakpoints (~chr7:69,938,691 and chr7:95,720,897)
#
# Output: depth_per_region.tsv ready for Supplementary Table.
# ----------------------------------------------------------------------------

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: failed at line $LINENO (exit $rc): $BASH_COMMAND" >&2; exit $rc' ERR

BAM="/Users/changym/Desktop/LR_WGS/Case2/WES/AA001181/AA001181.bam"
OUTDIR="/Users/changym/Desktop/LR_WGS/Case2/WES/Manta/coverage"

mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "==> Checking dependencies"
for cmd in samtools curl python3; do
    command -v "$cmd" >/dev/null || { echo "ERROR: $cmd missing in PATH" >&2; exit 1; }
done

# ----------------------------------------------------------------------------
# 1. AUTS2 exon coordinates from UCSC RefSeq (GRCh38)
# ----------------------------------------------------------------------------
echo "==> Fetching AUTS2 RefSeq from UCSC REST API"
curl -fsSL --retry 4 \
  "https://api.genome.ucsc.edu/getData/track?genome=hg38;track=ncbiRefSeqCurated;chrom=chr7;start=69599651;end=70829966" \
  -o ucsc_refseq.json

python3 - <<'PY' > auts2_exons.bed
import json, sys
with open("ucsc_refseq.json") as f:
    d = json.load(f)
items = d.get("ncbiRefSeqCurated", [])
chosen = None
# Prefer canonical NM_015570; fall back to any AUTS2 transcript
for t in items:
    if t.get("name2") == "AUTS2" and t.get("name","").startswith("NM_015570"):
        chosen = t; break
if chosen is None:
    for t in items:
        if t.get("name2") == "AUTS2":
            chosen = t; break
if chosen is None:
    sys.stderr.write("ERROR: no AUTS2 transcript in UCSC response\n"); sys.exit(1)

starts = [int(x) for x in chosen["exonStarts"].rstrip(",").split(",")]
ends   = [int(x) for x in chosen["exonEnds"].rstrip(",").split(",")]
strand = chosen["strand"]
n = len(starts)
sys.stderr.write(
    f"  Using transcript {chosen['name']} ({chosen['name2']}, "
    f"strand={strand}, {n} exons, span {chosen.get('txStart','?')}-{chosen.get('txEnd','?')})\n"
)
for i,(s,e) in enumerate(zip(starts, ends), 1):
    exon_num = i if strand == "+" else n - i + 1
    print(f"chr7\t{s}\t{e}\tAUTS2_exon{exon_num:02d}")
PY

echo "    Wrote $(wc -l < auts2_exons.bed | tr -d ' ') AUTS2 exons -> auts2_exons.bed"

# ----------------------------------------------------------------------------
# 2. Positive control + LRS breakpoint windows (1 kb each)
# ----------------------------------------------------------------------------
cat > extra_regions.bed <<'EOF'
chr17	7675994	7676272	TP53_exon4_positiveControl
chr7	69938191	69939191	LRS_breakpoint_chr7_69938691_AUTS2_intron2
chr7	95720397	95721397	LRS_breakpoint_chr7_95720897_7q21.3
EOF

cat auts2_exons.bed extra_regions.bed > regions.bed
echo "    Total regions to score: $(wc -l < regions.bed | tr -d ' ')"

# ----------------------------------------------------------------------------
# 3. Mean depth per region
# ----------------------------------------------------------------------------
echo "==> Computing mean depth per region with samtools depth -a"
echo -e "name\tchrom\tstart\tend\tlength_bp\tmean_depth" > depth_per_region.tsv
while IFS=$'\t' read -r chr start end name; do
    region="${chr}:$((start+1))-${end}"
    len=$((end - start))
    stats=$(samtools depth -a -r "$region" "$BAM" \
        | awk -v len="$len" '
              {s+=$3; n++}
              END{ if(n>0) printf "%d\t%.2f", n, s/n;
                   else    printf "%d\t0.00", len }
          ')
    echo -e "${name}\t${chr}\t${start}\t${end}\t${stats}" >> depth_per_region.tsv
done < regions.bed

echo
echo "==> RESULTS"
column -t -s $'\t' depth_per_region.tsv
echo
echo "Output: $OUTDIR/depth_per_region.tsv"
