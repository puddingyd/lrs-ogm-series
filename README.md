# LRS + OGM resolution of "balanced" chromosomal rearrangements in NDD probands

Companion repository for:

> Chang Y-M, Pan Y-W, Tsai M-C, Wu P-M, Kuo P-L, Chou Y-Y.
> *Deciphering cryptic aberrations in "balanced" chromosomal rearrangements in
> neurodevelopmental disorders using integrated long-read sequencing and
> optical genome mapping.*
> Submitted to **npj Genomic Medicine**, 2026.

This repository hosts the consolidated breakpoint summary, per-case
prioritization outputs, and the analysis pipelines that support the
manuscript. 

## Repository layout

```
.
├── README.md                                  this file
├── data/
│   ├── breakpoint_coordinates.tsv             14-SV consolidated summary
│   │                                            with ACMG/AMP classifications
│   └── manual_review_candidates/              per-case prioritization outputs
│       ├── case{1,2,3}_pbsv.tsv               pbsv-derived SVs retained for
│       │                                            manual review
│       └── case{1,2,3}_hificnv.tsv            HiFiCNV-derived CNVs retained
│                                                    for manual review
└── scripts/
    ├── pipeline/                              generic LRS analysis pipeline,
    │                                            reusable for any HiFi sample
    │   ├── hifi_bam_qc.sh
    │   ├── pbsv_vcf_plus_annotsv_summary.sh
    │   └── hificnv_vcf_plus_annotsv_summary.sh
    └── case2_wes_reanalysis/                  Case 2 retrospective short-read
                                                  WES re-analysis to verify
                                                  that the AUTS2-disrupting
                                                  inversion is inaccessible
                                                  to short-read WES
        ├── compute_auts2_exon_depth.sh
        ├── run_manta_case2.sh
        └── run_delly_case2.sh
```

## Data

### `data/breakpoint_coordinates.tsv`
Consolidated machine-readable summary of every structural / copy-number
variant identified across the three probands. 14 rows × 14 columns:

| Column | Description |
|---|---|
| `case` | Proband number (1-3) |
| `variant_id` | Stable identifier used elsewhere in the manuscript |
| `chrom1`, `start1`, `end1` | First breakpoint locus (GRCh38) |
| `chrom2`, `start2`, `end2` | Second breakpoint / partner locus (GRCh38) |
| `size_bp` | Variant size in base pairs (NA for translocation breakends) |
| `sv_type` | deletion / inversion / translocation breakend / segment relocation |
| `genes_affected` | Gene-content summary (counts and selected gene symbols) |
| `mechanism` | Inferred repair mechanism / context |
| `acmg_classification` | Pathogenic / Likely pathogenic / VUS |
| `acmg_score` | Riggs 2020 numeric score (CNVs) or ACMG/AMP criteria string (gene-disrupting copy-neutral SVs) |

Across the 14 variants:
1 Pathogenic, 2 Likely pathogenic, 11 VUS.

### `data/manual_review_candidates/`
Six per-case TSVs (3 probands × 2 callers) listing the SVs / CNVs that passed
the structured filtering pipeline and were retained for manual review. Each
entry includes the variant call, AnnotSV annotation, OMIM / dbVar / ClinVar
overlap, and Exomiser phenotype-relevance score:

| File | Caller | Rows | Columns |
|---|---|---:|---:|
| `case1_pbsv.tsv` | pbsv | 63 | 18 |
| `case1_hificnv.tsv` | HiFiCNV | 11 | 16 |
| `case2_pbsv.tsv` | pbsv | 72 | 18 |
| `case2_hificnv.tsv` | HiFiCNV | 11 | 16 |
| `case3_pbsv.tsv` | pbsv | 70 | 18 |
| `case3_hificnv.tsv` | HiFiCNV | 15 | 16 |

The manuscript figures and Sup Tables 4 and 5 summarise how these candidate
sets were narrowed to the final SV set reported per case.

## Scripts

### `scripts/pipeline/` — generic LRS analysis pipeline

The manuscript's three probands were analysed with these exact scripts.

```bash
# (a) BAM-level QC: mapping rate, mean depth, read-length distribution
bash scripts/pipeline/hifi_bam_qc.sh /path/to/case1.bam /path/to/case2.bam …

# (b) pbsv structural-variant prioritisation
#     Inputs: pbsv VCF + AnnotSV TSV (named <basename>_annotsv.tsv in same dir)
bash scripts/pipeline/pbsv_vcf_plus_annotsv_summary.sh \
    -v /path/to/caseN.pbsv.vcf.gz \
    -o caseN_pbsv_summary.tsv

# (c) HiFiCNV copy-number prioritisation
bash scripts/pipeline/hificnv_vcf_plus_annotsv_summary.sh \
    -v /path/to/caseN.hificnv.vcf.gz \
    -a /path/to/caseN.hificnv_annotsv.tsv \
    -o caseN_hificnv_summary.tsv
```

Each prioritization script emits both a full `*_summary.tsv` and a
`*.manual_review_candidates.tsv` containing only the variants that pass the
structured filters (population rarity, exon/transcript disruption, OMIM
relevance, Exomiser_gene_pheno_score > 0). The `data/manual_review_candidates/`
directory contains the latter for the three probands in this study.

### `scripts/case2_wes_reanalysis/` — Case 2 retrospective short-read WES

Verifies that the *AUTS2*-disrupting inversion in Case 2 was inaccessible to
the original whole-exome sequencing (Roche KAPA HyperExome Plus capture kit)
at the read level — independently of the variant caller. Both Manta and Delly
re-analysis return zero SV records within ±50 kb of either LRS-defined
breakpoint, against background per-base read depths of 0.07× and 0.16×
(versus a median of 106× across captured *AUTS2* exons).

Run on macOS (Apple Silicon) with Docker Desktop installed:

```bash
# (a) Manta v1.6.0 re-analysis (Docker; --platform linux/amd64 for Apple Silicon)
bash scripts/case2_wes_reanalysis/run_manta_case2.sh

# (b) Delly v1.2.6 re-analysis (independent caller corroboration)
bash scripts/case2_wes_reanalysis/run_delly_case2.sh

# (c) Per-AUTS2-exon read-depth computation feeding Supplementary Table 7
bash scripts/case2_wes_reanalysis/compute_auts2_exon_depth.sh
```

The reference is the `GRCh38_full_analysis_set_plus_decoy_hla` build 
(the same reference the BAM was aligned against); the path to a local copy 
is provided in `run_manta_case2.sh`. `compute_auts2_exon_depth.sh` queries 
the UCSC RefSeq REST API at run time, so an internet connection is required.

## Data availability

- **Filtered SV / CNV calls** (no patient identifiers):
  `data/manual_review_candidates/`
- **Consolidated breakpoint coordinates and ACMG classifications**:
  `data/breakpoint_coordinates.tsv`
- **ClinVar**: 5 of the 14 variants (the 1 Pathogenic + 2 Likely pathogenic +
  2 VUS) were submitted to ClinVar; accession numbers will be added to the
  published manuscript once curated by ClinVar.
- **Repository archive**: the public release accompanying the manuscript is
  archived at Zenodo and citable by DOI; the DOI is reported in the
  manuscript Data availability statement.
- **Raw HiFi BAM and Bionano OGM bnx files** contain identifiable
  sequence-level data and, in accordance with the IRB-approved protocol
  (NCKUH A-BR-109-045), are **available from the corresponding authors upon
  reasonable request**, subject to local ethics-board approval and a
  data-use agreement.

## Code availability

All scripts in this repository are released under the MIT licence (see
[Licence](#licence) below). External tool versions used in the manuscript:

| Tool | Version |
|---|---|
| pbmm2 | v1.16.0 |
| pbsv | v2.10.0 |
| HiFiCNV | v1.0.1 |
| DeepVariant | v1.6.1 (PacBio model) |
| mosdepth | v0.3.9 |
| Bionano Solve | v3.7.2 |
| Bionano Access | v1.7.2 |
| AnnotSV | latest at time of analysis |
| VEP | v115 |
| ANNOVAR | release 2024-04-30 |
| Manta (Case 2 re-analysis) | v1.6.0 |
| Delly (Case 2 re-analysis) | v1.2.6 |

## Citation

If you use any code or data from this repository, please cite the manuscript
above (citation will be updated upon acceptance).

## Licence

Code in `scripts/` is released under the MIT licence. Data files in `data/`
are released under CC0 (public domain).

## Contact

- **Lead corresponding author**: Yen-Yin Chou — yenyin01@gmail.com
- **Senior corresponding author**: Pao-Lin Kuo — paolinkuo@gmail.com

Department of Genomic Medicine and Department of Pediatrics,
National Cheng Kung University Hospital, Tainan, Taiwan.
