#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  bash pbsv_vcf_plus_annotsv_summary.sh \
    -v /path/to/case1.vcf.gz \
    -o output_summary.tsv \
    [-d 8] \
    [-a 2] \
    [-f 0.20]

Required:
  -v   input pbsv VCF(.vcf.gz)
  -o   output summary TSV

Optional:
  -d   min FORMAT/DP for strict filter [default: 8]
  -a   min alt support using FORMAT/AD alt field [default: 2]
  -f   min alt fraction ADalt/(ADref+ADalt) [default: 0.20]

Rule:
  AnnotSV TSV must be in the same directory and named:
    <basename>_annotsv.tsv

Outputs:
  1. summary TSV specified by -o
  2. manual review candidate TSV:
       <summary_basename>.manual_review_candidates.tsv
EOF
  exit 1
}

VCF=""
OUT_TSV=""
MIN_DP="8"
MIN_ALT="2"
MIN_AFRACTION="0.20"

while getopts "v:o:d:a:f:" opt; do
  case $opt in
    v) VCF="$OPTARG" ;;
    o) OUT_TSV="$OPTARG" ;;
    d) MIN_DP="$OPTARG" ;;
    a) MIN_ALT="$OPTARG" ;;
    f) MIN_AFRACTION="$OPTARG" ;;
    *) usage ;;
  esac
done

[[ -z "$VCF" || -z "$OUT_TSV" ]] && usage
[[ ! -f "$VCF" ]] && { echo "ERROR: input VCF not found: $VCF" >&2; exit 1; }

for cmd in bcftools awk mktemp wc tr; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: missing tool: $cmd" >&2; exit 1; }
done

VCF_DIR="$(cd "$(dirname "$VCF")" && pwd)"
VCF_FILE="$(basename "$VCF")"
BASE="${VCF_FILE%.vcf.gz}"
BASE="${BASE%.vcf}"
ANNOTSV_TSV="$VCF_DIR/${BASE}_annotsv.tsv"

[[ ! -f "$ANNOTSV_TSV" ]] && {
  echo "ERROR: AnnotSV TSV not found: $ANNOTSV_TSV" >&2
  exit 1
}

OUT_DIR="$(cd "$(dirname "$OUT_TSV")" && pwd)"
OUT_FILE="$(basename "$OUT_TSV")"
OUT_BASE="${OUT_FILE%.tsv}"
MANUAL_TSV="$OUT_DIR/${OUT_BASE}.manual_review_candidates.tsv"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

RAW_VCF="$TMPDIR/raw.vcf.gz"
PASS_VCF="$TMPDIR/pass.vcf.gz"
STRICT_VCF="$TMPDIR/strict.vcf.gz"

count_total() {
  bcftools view -H "$1" | wc -l | tr -d " "
}

extract_type_count() {
  local vcf="$1"
  local svtype="$2"
  bcftools query -f '%INFO/SVTYPE\n' "$vcf" 2>/dev/null | \
    awk -v t="$svtype" '$1==t{n++} END{print n+0}'
}

########################################
# Part 1: metrics from pbsv VCF
########################################

bcftools sort -Oz -o "$RAW_VCF" "$VCF"
bcftools index -f "$RAW_VCF" >/dev/null 2>&1 || true

bcftools view \
  -i 'FILTER="PASS" && (INFO/SVLEN="." || ABS(INFO/SVLEN)>=50)' \
  -Oz -o "$PASS_VCF" "$RAW_VCF"
bcftools index -f "$PASS_VCF" >/dev/null 2>&1 || true

bcftools view \
  -i "FILTER=\"PASS\" && (INFO/SVLEN=\".\" || ABS(INFO/SVLEN)>=50) && FORMAT/DP[0]>=${MIN_DP} && FORMAT/AD[0:1]>=${MIN_ALT} && (FORMAT/AD[0:0]+FORMAT/AD[0:1])>0 && (FORMAT/AD[0:1]/(FORMAT/AD[0:0]+FORMAT/AD[0:1]))>=${MIN_AFRACTION}" \
  -Oz -o "$STRICT_VCF" "$RAW_VCF"
bcftools index -f "$STRICT_VCF" >/dev/null 2>&1 || true

RAW_SV=$(count_total "$RAW_VCF")
RAW_DEL=$(extract_type_count "$RAW_VCF" "DEL")
RAW_INS=$(extract_type_count "$RAW_VCF" "INS")
RAW_INV=$(extract_type_count "$RAW_VCF" "INV")
RAW_DUP=$(extract_type_count "$RAW_VCF" "DUP")
RAW_BND=$(extract_type_count "$RAW_VCF" "BND")
PASS_SV=$(count_total "$PASS_VCF")
STRICT_SV=$(count_total "$STRICT_VCF")

########################################
# Part 2: metrics + manual candidates from AnnotSV TSV
########################################

AWK_OUT="$TMPDIR/annotsv_metrics_and_candidates.txt"

awk -F'\t' -v OFS='\t' -v MANUAL_TSV="$MANUAL_TSV" '
BEGIN {
  header_written=0
}
NR==1 {
  for (i=1; i<=NF; i++) idx[$i]=i
  next
}
{
  id=""
  mode=""
  gene=""
  loc=""
  loc2=""
  exomiser=""
  omim_pheno=""
  omim_morbid=""
  p_gain=""
  p_loss=""
  p_ins=""
  b_gain=""
  b_loss=""
  b_ins=""
  b_inv=""
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
  if ("Location" in idx) loc=$(idx["Location"])
  if ("Location2" in idx) loc2=$(idx["Location2"])
  if ("Exomiser_gene_pheno_score" in idx) exomiser=$(idx["Exomiser_gene_pheno_score"])
  if ("OMIM_phenotype" in idx) omim_pheno=$(idx["OMIM_phenotype"])
  if ("OMIM_morbid" in idx) omim_morbid=$(idx["OMIM_morbid"])

  if ("P_gain_source" in idx) p_gain=$(idx["P_gain_source"])
  if ("P_loss_source" in idx) p_loss=$(idx["P_loss_source"])
  if ("P_ins_source" in idx) p_ins=$(idx["P_ins_source"])

  if ("B_gain_source" in idx) b_gain=$(idx["B_gain_source"])
  if ("B_loss_source" in idx) b_loss=$(idx["B_loss_source"])
  if ("B_ins_source" in idx) b_ins=$(idx["B_ins_source"])
  if ("B_inv_source" in idx) b_inv=$(idx["B_inv_source"])

  if ("SV_chrom" in idx) chrom=$(idx["SV_chrom"])
  if ("SV_start" in idx) start=$(idx["SV_start"])
  if ("SV_end" in idx) end=$(idx["SV_end"])
  if ("SV_length" in idx) svlen=$(idx["SV_length"])
  if ("SV_type" in idx) svtype=$(idx["SV_type"])
  if ("AnnotSV_ranking_score" in idx) ranking=$(idx["AnnotSV_ranking_score"])
  if ("ACMG_class" in idx) acmg=$(idx["ACMG_class"])
  if ("PhenoGenius_phenotype" in idx) pheno_txt=$(idx["PhenoGenius_phenotype"])

  if (!(id in seen_id)) seen_id[id]=1

  # population filtered flag
  popflag=1
  if (b_gain != "" && b_gain != "." && b_gain != "NA") popflag=0
  if (b_loss != "" && b_loss != "." && b_loss != "NA") popflag=0
  if (b_ins  != "" && b_ins  != "." && b_ins  != "NA") popflag=0
  if (b_inv  != "" && b_inv  != "." && b_inv  != "NA") popflag=0
  if (popflag==0) nonpop[id]=1

  # pathogenic overlap override flag
  pathflag=0
  if (p_gain != "" && p_gain != "." && p_gain != "NA") pathflag=1
  if (p_loss != "" && p_loss != "." && p_loss != "NA") pathflag=1
  if (p_ins  != "" && p_ins  != "." && p_ins  != "NA") pathflag=1
  if (pathflag==1) pathhit[id]=1

  if (mode != "split") next

  if (gene != "" && gene != ".") split_gene[id]=1

  exonflag=0
  if (gene != "" && gene != ".") {
    if (loc ~ /exon/) exonflag=1
    if (loc2 ~ /CDS/) exonflag=1
    if (loc == "txStart-txEnd") exonflag=1
    if (loc2 == "5'\''UTR-3'\''UTR") exonflag=1
    if (loc ~ /splice/) exonflag=1
    if (loc2 ~ /splice/) exonflag=1
  }
  if (exonflag==1) split_exon[id]=1

  phenoflag=0
  if (exomiser != "" && exomiser != "." && exomiser != "NA") {
    if ((exomiser + 0) > 0) phenoflag=1
  }
  if (phenoflag==1) split_pheno[id]=1

  omimflag=0
  if (omim_morbid != "" && omim_morbid != "." && omim_morbid != "NA" && omim_morbid != "no") omimflag=1
  if (omim_pheno != "" && omim_pheno != "." && omim_pheno != "NA") omimflag=1
  if (omimflag==1) split_omim[id]=1

  # representative row for output
  score=0
  if (pathflag==1) score+=8
  if (exonflag==1) score+=4
  if (phenoflag==1) score+=2
  if (omimflag==1) score+=1

  if (!(id in best_score) || score > best_score[id]) {
    best_score[id]=score
    cand_gene[id]=gene
    cand_loc[id]=loc
    cand_loc2[id]=loc2
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
  pop_n=0
  path_n=0
  gene_n=0
  exon_n=0
  pheno_n=0
  omim_n=0
  manual_n=0

  for (id in seen_id) {
    if (!(id in nonpop)) {
      popfilt[id]=1
      pop_n++
    }
  }

  for (id in pathhit) path_n++
  for (id in split_gene) if (id in popfilt) genehit[id]=1
  for (id in split_exon) if (id in popfilt) exonhit[id]=1
  for (id in split_pheno) if (id in popfilt) phenohit[id]=1
  for (id in split_omim) if (id in popfilt) omimhit[id]=1

  for (id in genehit) gene_n++
  for (id in exonhit) exon_n++
  for (id in phenohit) pheno_n++
  for (id in omimhit) omim_n++

  print "AnnotSV_ID","SV_chrom","SV_start","SV_end","SV_length","SV_type","Gene_name","Location","Location2","Exomiser_gene_pheno_score","OMIM_phenotype","OMIM_morbid","P_gain_source","P_loss_source","P_ins_source","AnnotSV_ranking_score","ACMG_class","PhenoGenius_phenotype" > MANUAL_TSV

  for (id in seen_id) {
    keep=0

    # population-filtered route
    if ((id in popfilt) && (id in exonhit) && ((id in phenohit) || (id in omimhit))) {
      keep=1
    }

    # pathogenic overlap override
    if (id in pathhit) {
      keep=1
    }

    if (keep==1) {
      manual[id]=1
    }
  }

  for (id in manual) {
    manual_n++
    print id, cand_chrom[id], cand_start[id], cand_end[id], cand_svlen[id], cand_svtype[id], cand_gene[id], cand_loc[id], cand_loc2[id], cand_exomiser[id], cand_omim_pheno[id], cand_omim_morbid[id], cand_p_gain[id], cand_p_loss[id], cand_p_ins[id], cand_ranking[id], cand_acmg[id], cand_pheno_txt[id] >> MANUAL_TSV
  }

  print pop_n, path_n, gene_n, exon_n, pheno_n, omim_n, manual_n
}
' "$ANNOTSV_TSV" > "$AWK_OUT"

read -r POPULATION_FILTERED_SV PATHOGENIC_OVERLAP_SV GENE_OVERLAP_SV EXON_DISRUPTING_SV PHENOTYPE_RELEVANT_SV OMIM_RELEVANT_SV MANUAL_REVIEW_SV < "$AWK_OUT"

########################################
# Output summary
########################################

echo -e "Case\tRaw_SV\tRaw_DEL\tRaw_INS\tRaw_INV\tRaw_DUP\tRaw_BND\tPASS_SV\tStrict_SV\tPopulationFiltered_SV\tPathogenicOverlap_SV\tGeneOverlap_SV\tExonDisrupting_SV\tPhenotypeRelevant_SV\tOMIMRelevant_SV\tManualReview_SV" > "$OUT_TSV"

echo -e "${BASE}\t${RAW_SV}\t${RAW_DEL}\t${RAW_INS}\t${RAW_INV}\t${RAW_DUP}\t${RAW_BND}\t${PASS_SV}\t${STRICT_SV}\t${POPULATION_FILTERED_SV}\t${PATHOGENIC_OVERLAP_SV}\t${GENE_OVERLAP_SV}\t${EXON_DISRUPTING_SV}\t${PHENOTYPE_RELEVANT_SV}\t${OMIM_RELEVANT_SV}\t${MANUAL_REVIEW_SV}" >> "$OUT_TSV"

echo "[INFO] VCF: $VCF" >&2
echo "[INFO] AnnotSV TSV: $ANNOTSV_TSV" >&2
echo "[INFO] Summary output: $OUT_TSV" >&2
echo "[INFO] Manual review candidates: $MANUAL_TSV" >&2
