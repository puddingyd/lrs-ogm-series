#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  bash hificnv_vcf_plus_annotsv_summary.sh \
    -v /path/to/case1.hificnv.vcf.gz \
    -a /path/to/case1.hificnv_annotsv.tsv \
    -o output_summary.tsv \
    [-l 100000]

Required:
  -v   input HiFiCNV VCF(.vcf.gz)
  -a   AnnotSV TSV corresponding to the HiFiCNV VCF
  -o   output summary TSV

Optional:
  -l   minimum absolute SV length (bp) for Large_DEL_CNV / Large_DUP_CNV [default: 100000]

Outputs:
  1. summary TSV specified by -o
  2. manual review candidate TSV:
       <summary_basename>.manual_review_candidates.tsv
EOF
  exit 1
}

VCF=""
ANNOTSV_TSV=""
OUT_TSV=""
MIN_LEN="100000"

while getopts "v:a:o:l:" opt; do
  case $opt in
    v) VCF="$OPTARG" ;;
    a) ANNOTSV_TSV="$OPTARG" ;;
    o) OUT_TSV="$OPTARG" ;;
    l) MIN_LEN="$OPTARG" ;;
    *) usage ;;
  esac
done

[[ -z "$VCF" || -z "$ANNOTSV_TSV" || -z "$OUT_TSV" ]] && usage
[[ ! -f "$VCF" ]] && { echo "ERROR: input VCF not found: $VCF" >&2; exit 1; }
[[ ! -f "$ANNOTSV_TSV" ]] && { echo "ERROR: AnnotSV TSV not found: $ANNOTSV_TSV" >&2; exit 1; }

for cmd in bcftools awk mktemp wc tr; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: missing tool: $cmd" >&2; exit 1; }
done

VCF_FILE="$(basename "$VCF")"
BASE="${VCF_FILE%.vcf.gz}"
BASE="${BASE%.vcf}"

OUT_DIR="$(cd "$(dirname "$OUT_TSV")" && pwd)"
OUT_FILE="$(basename "$OUT_TSV")"
OUT_BASE="${OUT_FILE%.tsv}"
MANUAL_TSV="$OUT_DIR/${OUT_BASE}.manual_review_candidates.tsv"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
SORTED_VCF="$TMPDIR/sorted.vcf.gz"

count_total() {
  bcftools view -H "$1" | wc -l | tr -d ' '
}

extract_pass_type_count() {
  local vcf="$1"
  local svtype="$2"
  bcftools view -i "FILTER=\"PASS\" && INFO/SVTYPE=\"${svtype}\"" -H "$vcf" | wc -l | tr -d ' '
}

count_large_type() {
  local vcf="$1"
  local svtype="$2"
  local bp="$3"
  bcftools query -f '%FILTER\t%INFO/SVTYPE\t%INFO/SVLEN\n' "$vcf" 2>/dev/null | \
    awk -F'\t' -v T="$svtype" -v L="$bp" '
      $1=="PASS" && $2==T {
        len=$3
        gsub(/^-/, "", len)
        if (len+0 >= L) n++
      }
      END { print n+0 }'
}

########################################
# Part 1: metrics from HiFiCNV VCF
########################################

bcftools sort -Oz -o "$SORTED_VCF" "$VCF"
bcftools index -f "$SORTED_VCF" >/dev/null 2>&1 || true

RAW_CNV=$(count_total "$SORTED_VCF")
PASS_CNV=$(bcftools view -i 'FILTER="PASS"' -H "$SORTED_VCF" | wc -l | tr -d ' ')
DEL_CNV=$(extract_pass_type_count "$SORTED_VCF" "DEL")
DUP_CNV=$(extract_pass_type_count "$SORTED_VCF" "DUP")
LARGE_DEL_CNV=$(count_large_type "$SORTED_VCF" "DEL" "$MIN_LEN")
LARGE_DUP_CNV=$(count_large_type "$SORTED_VCF" "DUP" "$MIN_LEN")

########################################
# Part 2: metrics + manual candidates from AnnotSV TSV
########################################

AWK_OUT="$TMPDIR/annotsv_metrics_and_candidates.txt"

awk -F'\t' -v OFS='\t' -v MANUAL_TSV="$MANUAL_TSV" '
NR==1 {
  for (i=1; i<=NF; i++) idx[$i]=i
  next
}
{
  id=""
  mode=""
  gene=""
  exomiser=""
  omim_pheno=""
  omim_morbid=""
  p_gain=""
  p_loss=""
  p_ins=""
  chrom=""
  start=""
  end=""
  svlen=""
  svtype=""
  ranking=""
  acmg=""
  pheno_txt=""

  if ("AnnotSV_ID" in idx) id=$(idx["AnnotSV_ID"])
  if ("Annotation_mode" in idx) mode=$(idx["Annotation_mode"])
  if ("Gene_name" in idx) gene=$(idx["Gene_name"])
  if ("Exomiser_gene_pheno_score" in idx) exomiser=$(idx["Exomiser_gene_pheno_score"])
  if ("OMIM_phenotype" in idx) omim_pheno=$(idx["OMIM_phenotype"])
  if ("OMIM_morbid" in idx) omim_morbid=$(idx["OMIM_morbid"])

  if ("P_gain_source" in idx) p_gain=$(idx["P_gain_source"])
  if ("P_loss_source" in idx) p_loss=$(idx["P_loss_source"])
  if ("P_ins_source" in idx) p_ins=$(idx["P_ins_source"])

  if ("SV_chrom" in idx) chrom=$(idx["SV_chrom"])
  if ("SV_start" in idx) start=$(idx["SV_start"])
  if ("SV_end" in idx) end=$(idx["SV_end"])
  if ("SV_length" in idx) svlen=$(idx["SV_length"])
  if ("SV_type" in idx) svtype=$(idx["SV_type"])
  if ("AnnotSV_ranking_score" in idx) ranking=$(idx["AnnotSV_ranking_score"])
  if ("ACMG_class" in idx) acmg=$(idx["ACMG_class"])
  if ("PhenoGenius_phenotype" in idx) pheno_txt=$(idx["PhenoGenius_phenotype"])

  seen_id[id]=1

  pathflag=0
  if (p_gain != "" && p_gain != "." && p_gain != "NA") pathflag=1
  if (p_loss != "" && p_loss != "." && p_loss != "NA") pathflag=1
  if (p_ins  != "" && p_ins  != "." && p_ins  != "NA") pathflag=1
  if (pathflag==1) pathhit[id]=1

  if (mode != "split") next

  if (exomiser != "" && exomiser != "." && exomiser != "NA") {
    if ((exomiser + 0) > 0) phenohit[id]=1
  }

  omimflag=0
  if (omim_morbid != "" && omim_morbid != "." && omim_morbid != "NA" && omim_morbid != "no") omimflag=1
  if (omim_pheno != "" && omim_pheno != "." && omim_pheno != "NA") omimflag=1
  if (omimflag==1) omimhit[id]=1

  score=0
  if (pathflag==1) score+=8
  if (id in phenohit) score+=4
  if (id in omimhit) score+=2
  if (gene != "" && gene != ".") score+=1

  if (!(id in best_score) || score > best_score[id]) {
    best_score[id]=score
    cand_gene[id]=gene
    cand_exomiser[id]=exomiser
    cand_omim_pheno[id]=omim_pheno
    cand_omim_morbid[id]=omim_morbid
    cand_p_gain[id]=p_gain
    cand_p_loss[id]=p_loss
    cand_p_ins[id]=p_ins
    cand_chrom[id]=chrom
    cand_start[id]=start
    cand_end[id]=end
    cand_svlen[id]=svlen
    cand_svtype[id]=svtype
    cand_ranking[id]=ranking
    cand_acmg[id]=acmg
    cand_pheno_txt[id]=pheno_txt
  }
}
END {
  path_n=0
  pheno_n=0
  omim_n=0
  manual_n=0

  for (id in pathhit) path_n++
  for (id in phenohit) pheno_n++
  for (id in omimhit) omim_n++

  print "AnnotSV_ID","SV_chrom","SV_start","SV_end","SV_length","SV_type","Gene_name","Exomiser_gene_pheno_score","OMIM_phenotype","OMIM_morbid","P_gain_source","P_loss_source","P_ins_source","AnnotSV_ranking_score","ACMG_class","PhenoGenius_phenotype" > MANUAL_TSV

  for (id in seen_id) {
    if ((id in phenohit) || (id in omimhit) || (id in pathhit)) {
      manual_n++
      print id, cand_chrom[id], cand_start[id], cand_end[id], cand_svlen[id], cand_svtype[id], cand_gene[id], cand_exomiser[id], cand_omim_pheno[id], cand_omim_morbid[id], cand_p_gain[id], cand_p_loss[id], cand_p_ins[id], cand_ranking[id], cand_acmg[id], cand_pheno_txt[id] >> MANUAL_TSV
    }
  }

  print path_n, pheno_n, omim_n, manual_n
}
' "$ANNOTSV_TSV" > "$AWK_OUT"

read -r PATHOGENIC_OVERLAP_CNV PHENOTYPE_RELEVANT_CNV OMIM_RELEVANT_CNV MANUAL_REVIEW_CNV < "$AWK_OUT"

echo -e "Case\tRaw_CNV\tPASS_CNV\tDEL_CNV\tDUP_CNV\tLarge_DEL_CNV\tLarge_DUP_CNV\tPathogenicOverlap_CNV\tPhenotypeRelevant_CNV\tOMIMRelevant_CNV\tManualReview_CNV" > "$OUT_TSV"
echo -e "${BASE}\t${RAW_CNV}\t${PASS_CNV}\t${DEL_CNV}\t${DUP_CNV}\t${LARGE_DEL_CNV}\t${LARGE_DUP_CNV}\t${PATHOGENIC_OVERLAP_CNV}\t${PHENOTYPE_RELEVANT_CNV}\t${OMIM_RELEVANT_CNV}\t${MANUAL_REVIEW_CNV}" >> "$OUT_TSV"

echo "[INFO] VCF: $VCF" >&2
echo "[INFO] AnnotSV TSV: $ANNOTSV_TSV" >&2
echo "[INFO] Large CNV threshold: ${MIN_LEN} bp" >&2
echo "[INFO] Summary output: $OUT_TSV" >&2
echo "[INFO] Manual review candidates: $MANUAL_TSV" >&2