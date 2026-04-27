#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: bash $0 <bam1> [bam2 ...]" >&2
  exit 1
fi

for cmd in samtools awk; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' not found in PATH" >&2
    exit 1
  fi
done

OUT_TSV="bam_qc_metrics.tsv"
PRIMARY_EXCLUDE=$((0x100 + 0x800))

echo -e "bam\tnum_reads\tmapping_rate\tmean_read_length\tmax_read_length\tmean_depth" > "$OUT_TSV"

for BAM in "$@"; do
  if [[ ! -f "$BAM" ]]; then
    echo "Warning: file not found, skip: $BAM" >&2
    continue
  fi

  if [[ ! -f "${BAM}.bai" && ! -f "${BAM%.bam}.bai" ]]; then
    echo "[INFO] Indexing $BAM" >&2
    samtools index "$BAM"
  fi

  SAMPLE="$(basename "$BAM")"
  echo "[INFO] Processing $SAMPLE" >&2

  NUM_READS=$(samtools view -c -F "$PRIMARY_EXCLUDE" "$BAM")
  MAPPED_READS=$(samtools view -c -F $((0x4 + PRIMARY_EXCLUDE)) "$BAM")

  if [[ "$NUM_READS" -gt 0 ]]; then
    MAPPING_RATE=$(awk -v m="$MAPPED_READS" -v n="$NUM_READS" 'BEGIN{printf "%.6f", (m/n)*100}')
  else
    MAPPING_RATE="NA"
  fi

  read -r MEAN_READ_LEN MAX_READ_LEN <<EOF
$(samtools view -F "$PRIMARY_EXCLUDE" "$BAM" | \
  awk '
    $10 != "*" {
      l=length($10);
      sum+=l;
      n++;
      if (l>max) max=l;
    }
    END {
      if (n>0) {
        printf "%.2f %d\n", sum/n, max
      } else {
        printf "NA NA\n"
      }
    }')
EOF

  MEAN_DEPTH=$(samtools depth -a -J -G "$PRIMARY_EXCLUDE" "$BAM" | \
    awk '{sum+=$3; n++} END{if(n>0) printf "%.6f", sum/n; else print "NA"}')

  echo -e "${SAMPLE}\t${NUM_READS}\t${MAPPING_RATE}\t${MEAN_READ_LEN}\t${MAX_READ_LEN}\t${MEAN_DEPTH}" >> "$OUT_TSV"
done

echo "[INFO] Done. Output: $OUT_TSV" >&2
