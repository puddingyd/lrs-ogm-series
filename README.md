# LRS + OGM resolution of "balanced" chromosomal rearrangements in NDD probands

Companion repository for:

> Chang YM, Pan YW, Tsai MC, Wu PM, Kuo PL, Chou YY.
> *Deciphering cryptic aberrations in "balanced" chromosomal rearrangements in
> neurodevelopmental disorders using integrated long-read sequencing and
> optical genome mapping.*
> Submitted to **npj Genomic Medicine**, 2026.

This repository contains the analysis pipelines, summary data files, and
manuscript revision history that support the submitted manuscript.

## Repository layout

```
.
├── README.md                                this file
├── manuscript/
│   ├── LRS_OGM_series_2026026_revised_v3.docx   ← latest submission file
│   ├── archive/                                  earlier docx versions + working notes
│   └── revision_scripts/                         python-docx scripts that generated the revisions
├── data/
│   ├── breakpoint_coordinates.tsv               consolidated SV breakpoint summary (all 14 SVs)
│   ├── clinvar_submissions.csv                  ClinVar submission template for the 5 P/LP variants
│   └── manual_review_candidates/                 per-case prioritisation outputs
│       ├── case{1,2,3}_pbsv.tsv                  pbsv calls retained for manual review
│       └── case{1,2,3}_hificnv.tsv               HiFiCNV calls retained for manual review
└── scripts/
    ├── pipeline/                                 generic LRS analysis (reusable for any sample)
    │   ├── hifi_bam_qc.sh
    │   ├── pbsv_vcf_plus_annotsv_summary.sh
    │   └── hificnv_vcf_plus_annotsv_summary.sh
    ├── case2_wes_reanalysis/                     Case 2 retrospective short-read WES re-analysis
    │   ├── download_grch38_analysis_set.sh
    │   ├── prepare_ref_for_manta.sh
    │   ├── run_manta_case2.sh
    │   ├── run_delly_case2.sh
    │   ├── compute_auts2_exon_depth.sh
    │   └── igv_screenshots.batch
    └── chromothripsis/                           Korbel & Campbell C2 oscillation analysis
        └── hificnv_oscillation.py
```

## Reproducing the analyses

### 1. Per-case SV / CNV prioritisation pipeline (`scripts/pipeline/`)

For each proband:

```bash
# (a) BAM-level QC (mapping rate, mean depth, read length distribution)
bash scripts/pipeline/hifi_bam_qc.sh /path/to/case1.bam /path/to/case2.bam …

# (b) pbsv structural-variant prioritisation
bash scripts/pipeline/pbsv_vcf_plus_annotsv_summary.sh \
    -v /path/to/caseN.pbsv.vcf.gz \
    -o caseN_pbsv_summary.tsv

# (c) HiFiCNV copy-number prioritisation
bash scripts/pipeline/hificnv_vcf_plus_annotsv_summary.sh \
    -v /path/to/caseN.hificnv.vcf.gz \
    -a /path/to/caseN.hificnv_annotsv.tsv \
    -o caseN_hificnv_summary.tsv
```

Each prioritisation script emits a *summary* TSV plus a
`*.manual_review_candidates.tsv` containing the SVs that passed all filtering
criteria (population-rarity, exon/transcript disruption, OMIM relevance,
phenotype concordance via Exomiser_gene_pheno_score). The committed
`data/manual_review_candidates/` directory contains the latter for the three
probands in this study.

### 2. Case 2 retrospective short-read WES re-analysis (`scripts/case2_wes_reanalysis/`)

To verify that the *AUTS2*-disrupting inversion in Case 2 was inaccessible to
the original whole-exome sequencing (Roche KAPA HyperExome Plus) at the read
level — independent of variant caller — re-run on a Mac:

```bash
# (a) Download the matching reference (GRCh38 + hs38d1 decoys + HLA, ~3 GB)
bash scripts/case2_wes_reanalysis/download_grch38_analysis_set.sh

# (b) (optional) build a smaller reference if your BAM uses only chrEBV decoy
bash scripts/case2_wes_reanalysis/prepare_ref_for_manta.sh

# (c) Manta and Delly re-analysis (Docker; runs on Apple Silicon via --platform linux/amd64)
bash scripts/case2_wes_reanalysis/run_manta_case2.sh
bash scripts/case2_wes_reanalysis/run_delly_case2.sh

# (d) Per-AUTS2-exon depth computation (depth.tsv data feeding Supplementary Table 6)
bash scripts/case2_wes_reanalysis/compute_auts2_exon_depth.sh

# (e) (optional) IGV batch script to generate the four-panel coverage figure
/Applications/IGV_<version>.app/Contents/MacOS/IGV \
    -b scripts/case2_wes_reanalysis/igv_screenshots.batch
```

Across both Manta v1.6.0 and Delly v1.2.6, **0 SV records** fall within ±50 kb
of either LRS-defined breakpoint, against background per-base read depths of
0.07× and 0.16× (versus a median of 106× across captured *AUTS2* exons).

### 3. Chromothripsis assessment (`scripts/chromothripsis/`)

Korbel & Campbell (Cell, 2013) C2 copy-number oscillation criterion applied to
the HiFiCNV per-segment output for Case 3 chromosomes 2, 5, 7 and 13:

```bash
# Edit COPYNUM_BEDGRAPH at the top to point at your local HiFiCNV output
python3 scripts/chromothripsis/hificnv_oscillation.py
```

In the manuscript we report this analysis cautiously as
*"features suggestive of chromoanagenesis"* — the HiFiCNV segment-level
resolution within the rearrangement region (≤25 Mb on chr2, ≤13 Mb on chr7) is
too coarse to formally adjudicate the C2 criterion.

## Data availability

- **Filtered SV / CNV calls** (no patient identifiers): `data/manual_review_candidates/`
  (per-case pbsv and HiFiCNV prioritisation outputs)
- **Breakpoint coordinates with ACMG classifications**: `data/breakpoint_coordinates.tsv`
- **ClinVar submissions**: 5 Pathogenic / Likely pathogenic variants
  (see `data/clinvar_submissions.csv`); accession SCV[pending]
- **Raw HiFi BAM and OGM bnx files** contain identifiable sequence-level data
  and, in accordance with the IRB-approved protocol (NCKUH A-BR-109-045), are
  **available from the corresponding authors upon reasonable request**, subject
  to local ethics-board approval and a data-use agreement.

## Code availability

All custom analysis scripts in this repository are released under the MIT
licence. A frozen Zenodo release accompanies each manuscript revision; see the
top-level Releases tab for the matching DOI.

## Manuscript revision history

The `manuscript/revision_scripts/` directory contains the python-docx scripts
that generated the iterative revisions of the docx file (`revise_manuscript.py`
for the initial pass, then `apply_round4.py` and `apply_round5.py` for
subsequent rounds; `diff_manuscript.py` produces a categorised paragraph-level
diff between the original and revised files). These scripts are committed for
reproducibility but are **not** required to use the analysis pipelines in
`scripts/`.

## Citation

If you use any code or data from this repository, please cite the manuscript
above (citation will be updated upon acceptance) and this repository
(`https://github.com/puddingyd/lrs-ogm-series`, Zenodo DOI: pending release).

## Licence

Code in `scripts/` and `manuscript/revision_scripts/` is released under the
MIT licence. The manuscript files in `manuscript/` are © 2026 the authors;
all rights reserved.

## Contact

- **Lead corresponding author**: Yen-Yin Chou — yenyin01@gmail.com
- **Senior corresponding author**: Pao-Lin Kuo — paolinkuo@gmail.com

Department of Genomic Medicine and Department of Pediatrics,
National Cheng Kung University Hospital, Tainan, Taiwan.
