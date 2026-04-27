# Manuscript revision diff (Abstract excluded)

Original : `LRS_OGM series 2026026.docx` — 146 non-empty paragraphs
Revised  : `LRS_OGM_series_2026026_revised.docx` — 167 non-empty paragraphs

## Summary by category

| Category | Count |
|---|---:|
| 🆕 New paragraphs (Abstract excluded) | **20** |
| ✏️ Substantive content modifications | **28** |
| 🔢 Reference-list entries reformatted (Nature style) | **35** |
| ⬆️ Body paragraphs only had citations changed to superscript | **8** |
| ➖ Deleted paragraphs | **0** |

Reference-list reformatting and citation→superscript changes are listed
only as counts (they affect every reference and most body paragraphs but
carry no scientific content change).

---

## 🆕 New paragraphs

### rev #9

> Abstract

### rev #93

> Ethics declarations

### rev #94

> The study was approved by the Institutional Review Board of National Cheng Kung University Hospital, Taiwan (IRB No. A-BR-109-045). Written informed consent was obtained from all adult participants or the legal guardians of pediatric probands. All participants (or legal guardians) provided written informed consent for the use of their de-identified medical and genetic data, including for publication.

### rev #95

> Acknowledgements

### rev #96

> We thank Wilson Cheng (PacBio) for providing bioinformatics analysis support, Blossom Biotechnologies, Inc. (Taiwan) for assistance in coordinating the long-read sequencing workflow, and Pharmigene, Inc. (Taiwan) for assistance with optical genome mapping.

### rev #97

> Author contributions

### rev #98

> Y.-M.C. — Methodology, Data curation, Formal analysis, Investigation, Software, Visualization, Writing – original draft. Y.-W.P. — Investigation, Resources. Y.-Y.C. — Investigation, Resources, Supervision, Writing – review & editing. M.-C.T. — Supervision, Writing – review & editing. P.-M.W. — Resources, Writing – review & editing. P.-L.K. — Conceptualization, Funding acquisition, Methodology, Supervision, Writing – review & editing.

### rev #99

> Funding

### rev #100

> This work was supported by the Clinical Medical Research Center, National Cheng Kung University Hospital (grant number NCKUH-11009023). The funder had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript.

### rev #101

> Competing interests

### rev #102

> The authors declare no competing interests.

### rev #103

> Data availability

### rev #104

> The data that support the findings of this study are available from the corresponding authors upon request. Restrictions apply because the data contain information that could compromise the privacy of the participants; access is therefore subject to local ethics-board approval.

### rev #105

> Code availability

### rev #106

> Custom analysis scripts are available from the corresponding authors upon request.

### rev #149

> 42. Korbel, J.O. & Campbell, P.J. Criteria for inference of chromothripsis in cancer genomes. Cell 152, 1226–36 (2013).

### rev #150

> 43. Chen, X., Schulz-Trieglaff, O., Shaw, R., Barnes, B., Schlesinger, F. et al. Manta: rapid detection of structural variants and indels for germline and cancer sequencing applications. Bioinformatics 32, 1220–2 (2016).

### rev #151

> 44. Rausch, T., Zichner, T., Schlattl, A., Stütz, A.M., Benes, V. & Korbel, J.O. DELLY: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics 28, i333–9 (2012).

### rev #165

> Supplementary Table 6. Retrospective short-read SV re-analysis of the Case 2 WES BAM (Manta v1.6.0 and Delly v1.2.6) and per-base read depth at AUTS2 exons (NM_015570.4) and at the LRS-defined inversion breakpoints.

### rev #166

> Footnote. Manta was run with --exome and without restricting --callRegions; Delly was run with default parameters. The reference used was GRCh38_full_analysis_set_plus_decoy_hla.fa. Per-base mean depth was computed with samtools depth -a. Across the 19 captured AUTS2 exons, mean depth ranged from 35.90× to 274.85× (median 106.09×). The two LRS-defined breakpoints (chr7:69,938,691, AUTS2 intron 2; chr7:95,720,897, 7q21.3) showed mean depths of 0.07× and 0.16×, respectively, and 0 / 0 records within ±50 kb in Manta diploidSV / candidateSV and Delly. Genome-wide, Manta produced 129 chromosome-7 candidate SVs and Delly produced 142 chromosome-7 SV records, confirming that both callers operated normally.

---

## ✏️ Substantive content modifications

### orig #1 → rev #1

OLD:
> Yu-Ming Chang a,b, Yu-Wen Pan b, Yen-Yin Chou a,b, Meng-Che Tsai a,b, Po-Ming Wu b, Pao-lin Kuo a,c,d

NEW:
> Yu-Ming Chang a,b, Yu-Wen Pan b, Meng-Che Tsai a,b, Po-Ming Wu b, Pao-Lin Kuo a,c,d, Yen-Yin Chou a,b

Inline diff:

```
Yu-Ming Chang a,b, Yu-Wen Pan b, 〔- Yen-Yin Chou a,b, -〕 Meng-Che Tsai a,b, Po-Ming Wu b, 〔- Pao-lin -〕 〔+ Pao-Lin +〕 Kuo 〔- a,c,d -〕 〔+ a,c,d, Yen-Yin Chou a,b +〕
```

### orig #6 → rev #6

OLD:
> Corresponding Author:

NEW:
> Corresponding authors:

Inline diff:

```
Corresponding 〔- Author: -〕 〔+ authors: +〕
```

### orig #7 → rev #7

OLD:
> Pao-Lin Kuo, Department of Obstetrics and Gynecology, National Cheng Kung University Hospital, 138 Sheng-Li Road, Tainan 704, Taiwan.

NEW:
> Yen-Yin Chou (lead corresponding author), Department of Genomic Medicine and Department of Pediatrics, National Cheng Kung University Hospital, 138 Sheng-Li Road, Tainan 704, Taiwan. E-mail: yenyin01@gmail.com

Inline diff:

```
〔- Pao-Lin Kuo, -〕 〔+ Yen-Yin Chou (lead corresponding author), +〕 Department of 〔- Obstetrics -〕 〔+ Genomic Medicine +〕 and 〔- Gynecology, -〕 〔+ Department of Pediatrics, +〕 National Cheng Kung University Hospital, 138 Sheng-Li Road, Tainan 704, Taiwan. 〔+ E-mail: yenyin01@gmail.com +〕
```

### orig #8 → rev #8

OLD:
> E-mail: paolinkuo@gmail.com

NEW:
> Pao-Lin Kuo, Department of Obstetrics and Gynecology, National Cheng Kung University Hospital, 138 Sheng-Li Road, Tainan 704, Taiwan. E-mail: paolinkuo@gmail.com

Inline diff:

```
〔+ Pao-Lin Kuo, Department of Obstetrics and Gynecology, National Cheng Kung University Hospital, 138 Sheng-Li Road, Tainan 704, Taiwan. +〕 E-mail: paolinkuo@gmail.com
```

### orig #16 → rev #18

OLD:
> We enrolled three unrelated probands referred to clinical genetics for neurodevelopmental features (including developmental delay, intellectual disability, autism spectrum disorder, and/or epilepsy). Each proband had de novo balanced chromosomal rearrangements identified by G-banded karyotyping and/or chromosomal microarray. Eligible patients were identified by their neurologists or clinical geneticists and recruited consecutively. Demographic data, personal and family histories, prior genetic test reports, and relevant examinations were abstracted from the medical record.

NEW:
> We enrolled three unrelated probands referred to clinical genetics for neurodevelopmental features (including developmental delay, intellectual disability, autism spectrum disorder, and/or epilepsy). Each proband had de novo balanced chromosomal rearrangements identified by G-banded karyotyping and/or chromosomal microarray. Eligible probands were recruited consecutively at National Cheng Kung University Hospital between March 2023 and October 2024 by referral from their attending neurologists or clinical geneticists. Demographic data, personal and family histories, prior genetic test reports, and relevant examinations were abstracted from the medical record.

Inline diff:

```
We enrolled three unrelated probands ref …  and/or chromosomal microarray. Eligible 〔- patients -〕 〔+ probands +〕 were 〔- identified -〕 〔+ recruited consecutively at National Cheng Kung University Hospital between March 2023 and October 2024 +〕 by 〔+ referral from +〕 their 〔+ attending +〕 neurologists or clinical 〔- geneticists and recruited consecutively. -〕 〔+ geneticists. +〕 Demographic data, personal and family hi … were abstracted from the medical record.
```

### orig #26 → rev #28

OLD:
> The extraction of ultra-high-molecular-weight genomic DNA (UMWH gDNA) from white blood cells was performed using the Bionano Prep SP-G2 Frozen Human Blood DNA Isolation Kit according to Bionano Genomics’ instructions (Bionano Genomics, San Diego, CA, USA). Briefly, cells were lysed using Proteinase K, and gDNA was bound to a magnetic disc, washed, and quantified once again using a Qubit device (Invitrogen Qubit Fluorometer 3, Thermo Fisher Scientific, Waltham, MA, USA). Following this, the DNA labeling was carried out using the Bionano DLS-G2 labeling kit. The methyltransferase DLE-1 enzyme was employed for the enzymatic labeling approach, specifically targeting the sequence motif CTTAAG within the DNA. The labeled DNA was loaded into the flowcell of the Saphyr chip (Bionano Genomics, San …

NEW:
> The extraction of ultra-high-molecular-weight genomic DNA (UHMW gDNA) from white blood cells was performed using the Bionano Prep SP-G2 Frozen Human Blood DNA Isolation Kit according to Bionano Genomics’ instructions (Bionano Genomics, San Diego, CA, USA). Briefly, cells were lysed using Proteinase K, and gDNA was bound to a magnetic disc, washed, and quantified once again using a Qubit device (Invitrogen Qubit Fluorometer 3, Thermo Fisher Scientific, Waltham, MA, USA). Following this, the DNA labeling was carried out using the Bionano DLS-G2 labeling kit. The methyltransferase DLE-1 enzyme was employed for the enzymatic labeling approach, specifically targeting the palindromic sequence motif CTTAAG (recognized on both strands of the DNA). The labeled DNA was loaded into the flowcell of th…

Inline diff:

```
The extraction of ultra-high-molecular-weight genomic DNA 〔- (UMWH -〕 〔+ (UHMW +〕 gDNA) from white blood cells was perform … ing approach, specifically targeting the 〔+ palindromic +〕 sequence motif CTTAAG 〔- within -〕 〔+ (recognized on both strands of +〕 the 〔- DNA. -〕 〔+ DNA). +〕 The labeled DNA was loaded into the flow … The run achieved a throughput of 500 Gb.
```

### orig #37 → rev #39

OLD:
> For alignment, HiFi reads were mapped to GRCh38/hg38 reference genome using pbmm2 (v1.16.0; CCS preset; default parameters), followed by coordinate sorting and indexing. Basic coverage and mapping metrics were computed with mosdepth (v0.3.9). SVs were called with pbsv (v2.10.0) using default analysis parameters. Small variants (SNVs/indels) were called from the aligned HiFi BAMs using DeepVariant (v1.6.1, PacBio model) to generate per-sample gVCF. Unless otherwise specified, default parameters were used for all tools in the PacBio HiFi human WGS WDL (v2.0.0). Quality metrics for long-read sequencing are summarized in Supplementary Table 3.

NEW:
> For alignment, HiFi reads were mapped to GRCh38/hg38 reference genome using pbmm2 (v1.16.0; CCS preset; default parameters), followed by coordinate sorting and indexing. Basic coverage and mapping metrics were computed with mosdepth (v0.3.9). SVs were called with pbsv (v2.10.0) using default analysis parameters. Copy-number variants were called with HiFiCNV (v1.0.1) using default parameters and the recommended GRCh38 exclude-region BED supplied with the tool, with sex automatically inferred from chromosome X / Y depth. Small variants (SNVs/indels) were called from the aligned HiFi BAMs using DeepVariant (v1.6.1, PacBio model) to generate per-sample gVCF. Unless otherwise specified, default parameters were used for all tools in the PacBio HiFi human WGS WDL (v2.0.0). Quality metrics for lon…

Inline diff:

```
For alignment, HiFi reads were mapped to … 10.0) using default analysis parameters. 〔+ Copy-number variants were called with HiFiCNV (v1.0.1) using default parameters and the recommended GRCh38 exclude-region BED supplied with the tool, with sex automatically inferred from chromosome X / Y depth. +〕 Small variants (SNVs/indels) were called … are summarized in Supplementary Table 3.
```

### orig #38 → rev #40

OLD:
> For downstream interpretation, CNVs and SVs were annotated and prioritized using AnnotSV (https://www.lbgi.fr/AnnotSV/), while SNVs and indels were filtered and prioritized using an in-house pipeline for small-variant interpretation. Breakpoints and copy-number changes were manually reviewed in IGV, and structural variant architecture and read-level configurations were further assessed using Ribbon (https://v2.genomeribbon.com/). The filtering and prioritization workflow for HiFiCNV-derived CNVs and pbsv-derived SVs is summarized in Supplementary Tables 4 and 5, respectively.

NEW:
> For downstream interpretation, SVs and CNVs were annotated and prioritized with AnnotSV (https://www.lbgi.fr/AnnotSV/). For SVs, pbsv calls with FILTER=PASS and SVLEN ≥50 bp were retained and filtered against AnnotSV benign/common population-resource annotations (default allele frequency >0.01); within this population-filtered set, exon- or transcript-disrupting SVs with phenotype relevance (Exomiser_gene_pheno_score >0, computed using HPO terms matched to each proband) or OMIM-disease relevance, as well as SVs overlapping known pathogenic regions, were carried forward for manual review. For CNVs, HiFiCNV calls with FILTER=PASS (default ≥100 kb) were retained and those with phenotype relevance, OMIM relevance, or overlap with known pathogenic regions (per AnnotSV annotation) were reviewed …

Inline diff:

```
For downstream interpretation, 〔+ SVs and +〕 CNVs 〔- and SVs -〕 were annotated and prioritized 〔+ with AnnotSV (https://www.lbgi.fr/AnnotSV/). For SVs, pbsv calls with FILTER=PASS and SVLEN ≥50 bp were retained and filtered against AnnotSV benign/common population-resource annotations (default allele frequency >0.01); within this population-filtered set, exon- or transcript-disrupting SVs with phenotype relevance (Exomiser_gene_pheno_score >0, computed +〕 using 〔+ HPO terms matched to each proband) or OMIM-disease relevance, as well as SVs overlapping known pathogenic regions, were carried forward for manual review. For CNVs, HiFiCNV calls with FILTER=PASS (default ≥100 kb) were retained and those with phenotype relevance, OMIM relevance, or overlap with known pathogenic regions (per +〕 AnnotSV 〔- (https://www.lbgi.fr/AnnotSV/), while SNVs and indels -〕 〔+ annotation) +〕 were 〔- filtered and prioritized using an in-house pipeline for small-variant interpretation. -〕 〔+ reviewed manually. +〕 Breakpoints and copy-number changes were 〔- manually reviewed -〕 〔+ inspected +〕 in 〔- IGV, and structural variant -〕 〔+ IGV; SV +〕 architecture and read-level configurations were further assessed 〔- using -〕 〔+ in +〕 Ribbon (https://v2.genomeribbon.com/). The 〔+ full +〕 filtering and prioritization 〔- workflow -〕 〔+ workflows +〕 for HiFiCNV-derived CNVs and pbsv-derived SVs 〔- is -〕 〔+ are +〕 summarized in Supplementary Tables 4 and 5, respectively. 〔+ In parallel, SNVs and indels were annotated with Ensembl Variant Effect Predictor (VEP v115) and ANNOVAR (release 2024-04-30), filtered against gnomAD v4.1 (allele frequency ≥0.01 excluded) and ClinVar (release 2025-12-08), and scored with AlphaMissense, MetaRNN, and SpliceAI. Variants were classified according to the American College of Medical Genetics and Genomics / Association for Molecular Pathology (ACMG/AMP) guideline. +〕
```

### orig #43 → rev #45

OLD:
> OGM, however, identified fusion calls linking 8p23.1 (chr8:10,756,153) to 8p22 (chr8:16,798,965) in an inverted orientation (Figure 1C-D). The copy-number profile also showed concordant losses across both deleted segments, spanning chr8:7,436,292-10,756,153 and chr8:12,012,778-16,798,965 (Figure 1C).

NEW:
> OGM, however, identified fusion calls linking 8p23.1 (chr8:10,756,153) to 8p22 (chr8:16,798,965) in an inverted orientation (Figure 1C-D). The copy-number profile also showed concordant losses across both deleted segments, spanning chr8:7,436,292-10,756,153 and chr8:12,012,778-16,798,965 (Figure 1C). We note that the genome-wide OGM CNV count in Case 1 was elevated owing to systematic coverage bias (Supplementary Table 1); the two true 8p deletions described above were nevertheless concordantly detected by OGM, LRS, and SNP array (Figure 1B–E), so the conclusions in Case 1 are not affected by this bias.

Inline diff:

```
OGM, however, identified fusion calls li …  chr8:12,012,778-16,798,965 (Figure 1C). 〔+ We note that the genome-wide OGM CNV count in Case 1 was elevated owing to systematic coverage bias (Supplementary Table 1); the two true 8p deletions described above were nevertheless concordantly detected by OGM, LRS, and SNP array (Figure 1B–E), so the conclusions in Case 1 are not affected by this bias. +〕
```

### orig #46 → rev #48

OLD:
> Breakpoint-level analysis provided insight into the mechanism underlying this rearrangement. Two breakpoints fall within the 8p low-copy repeats REPD (Repeat Distal) and REPP (Repeat Proximal)(Figure 1F). These junctions at chr8:8,174,929 (REPD) and chr8:12,477,756 (REPP) map inside homologous segments arranged in opposite orientation (based on the RepeatMasker track on the UCSC Genome Browser at  https://genome.ucsc.edu/; supporting snapshots in the Supplementary Figure 1). This configuration supports non-allelic homologous recombination (NAHR) mediated by REPD and REPP as the source of the inversion (Figure 1G). Sequence inspection of the remaining two junctions at chr8:10,756,153 and chr8:16,798,965 identified 4-bp microhomology at each, which is compatible with microhomology-mediated e…

NEW:
> Breakpoint-level analysis provided insight into the mechanism underlying this rearrangement. Two breakpoints fall within the 8p low-copy repeats REPD (Repeat Distal) and REPP (Repeat Proximal)(Figure 1F). These junctions at chr8:8,174,929 (REPD) and chr8:12,477,756 (REPP) map inside homologous segments arranged in opposite orientation (based on the RepeatMasker track on the UCSC Genome Browser at  https://genome.ucsc.edu/; supporting snapshots in the Supplementary Figure 1). This configuration supports non-allelic homologous recombination (NAHR) mediated by REPD and REPP as the source of the inversion. Sequence inspection of the remaining two junctions at chr8:10,756,153 and chr8:16,798,965 identified 4-bp microhomology at each, which is compatible with microhomology-mediated end-joining (…

Inline diff:

```
Breakpoint-level analysis provided insig … ed by REPD and REPP as the source of the 〔- inversion (Figure 1G). -〕 〔+ inversion. +〕 Sequence inspection of the remaining two …  with microhomology-mediated end-joining 〔- (MMEJ)(Figure 1G). -〕 〔+ (MMEJ); the proposed mechanism is summarized in Figure 1G. +〕 Taken together, the breakpoint anatomy s … CR boundaries contributed to the complex 〔- rearrangement. -〕 〔+ rearrangement.https://genome.ucsc.edu/ +〕
```

### orig #52 → rev #54

OLD:
> D. OGM evidence of intrachromosomal recombination between 8p23.1 (chr8:10,756,153) and 8p22 (chr8:16,798,965). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Note that the left portion of the proband map (middle tract) aligns in an inverted orientation to the reference around chr8:16.8 Mb (upper tract). The purple region marks the two OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

NEW:
> D. OGM evidence of intrachromosomal recombination between 8p23.1 (chr8:10,756,153) and 8p22 (chr8:16,798,965). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Note that the left portion of the proband map (middle track) aligns in an inverted orientation to the reference around chr8:16.8 Mb (upper track). The purple region marks the two OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

Inline diff:

```
D. OGM evidence of intrachromosomal reco …  left portion of the proband map (middle 〔- tract) -〕 〔+ track) +〕 aligns in an inverted orientation to the reference around chr8:16.8 Mb (upper 〔- tract). -〕 〔+ track). +〕 The purple region marks the two OGM labe … he breakpoint lies within this interval.
```

### orig #56 → rev #58

OLD:
> 3.3 Case 2

NEW:
> 3.2 Case 2

Inline diff:

```
〔- 3.3 -〕 〔+ 3.2 +〕 Case 2
```

### orig #65 → rev #67

OLD:
> C. Left panel showed the OGM circos plot of chromosome 7 highlighting the inversion (arc) and its two breakpoints. Right panel showed OGM evidence of an intrachromosomal fusion between 7q11.22 (chr7:69,922,416) and 7q21.3 (chr7:95,719,708). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Notably, the breakpoint at chr7:69.9 Mb disrupts AUTS2. The left portion of the proband map (middle tract) aligns in an inverted orientation to the reference around chr7:69.9 Mb (upper tract), consistent with an inversion. The purple region marks the two OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

NEW:
> C. Left panel showed the OGM circos plot of chromosome 7 highlighting the inversion (arc) and its two breakpoints. Right panel showed OGM evidence of an intrachromosomal fusion between 7q11.22 (chr7:69,922,416) and 7q21.3 (chr7:95,719,708). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Notably, the breakpoint at chr7:69.9 Mb disrupts AUTS2. The left portion of the proband map (middle track) aligns in an inverted orientation to the reference around chr7:69.9 Mb (upper track), consistent with an inversion. The purple region marks the two OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

Inline diff:

```
C. Left panel showed the OGM circos plot …  left portion of the proband map (middle 〔- tract) -〕 〔+ track) +〕 aligns in an inverted orientation to the reference around chr7:69.9 Mb (upper 〔- tract), -〕 〔+ track), +〕 consistent with an inversion. The purple … he breakpoint lies within this interval.
```

### orig #79 → rev #81

OLD:
> D. OGM evidence of an intrachromosomal fusion between 7q34 (chr7:139,632,423) and 7q35 (chr7:146,599,938). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Notably, the breakpoint at chr7:146.6 Mb disrupts CNTNAP2. The right portion of the proband map (middle track) aligns in an inverted orientation to the reference around chr7:69.9 Mb (upper tract). The purple region marks the OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

NEW:
> D. OGM evidence of an intrachromosomal fusion between 7q34 (chr7:139,632,423) and 7q35 (chr7:146,599,938). The proband is shown in green (middle track) and the references in blue (upper and lower tracks); gray connectors indicate alignment of the proband OGM labels to the corresponding reference labels. Notably, the breakpoint at chr7:146.6 Mb disrupts CNTNAP2. The right portion of the proband map (middle track) aligns in an inverted orientation to the reference around chr7:139 Mb (upper track). The purple region marks the OGM labels flanking the breakpoint, indicating that the breakpoint lies within this interval.

Inline diff:

```
D. OGM evidence of an intrachromosomal f … rted orientation to the reference around 〔- chr7:69.9 -〕 〔+ chr7:139 +〕 Mb (upper 〔- tract). -〕 〔+ track). +〕 The purple region marks the OGM labels f … he breakpoint lies within this interval.
```

### orig #83 → rev #85

OLD:
> Our study highlights the power of integrating LRS and OGM to resolve complex chromosomal rearrangements in patients with NDDs. Using this combined approach, we delineated the precise architectures of three seemingly balanced rearrangements initially identified by conventional cytogenetics. In each case, LRS and OGM analysis uncovered hidden genomic alterations or breakpoint details that were missed by karyotyping and microarray, thereby refining the genotype-phenotype correlations and providing clearer diagnostic insights. By resolving cryptic deletions and gene disruptions, our study confirms that applying advanced genomics can transform an initially “balanced” finding into a conclusive molecular diagnosis, supporting previous calls to integrate new technologies into cytogenetic analyses …

NEW:
> Our study highlights the power of integrating LRS and OGM to resolve complex chromosomal rearrangements in patients with NDDs. Using this combined approach, we delineated the precise architectures of three seemingly balanced rearrangements initially identified by conventional cytogenetics. In each case, LRS and OGM analysis uncovered hidden genomic alterations or breakpoint details that were missed by karyotyping and microarray, thereby refining the genotype-phenotype correlations and providing clearer diagnostic insights. By resolving cryptic deletions and gene disruptions, our study confirms that applying advanced genomics can transform an initially “balanced” finding into a conclusive molecular diagnosis, supporting previous calls to integrate new technologies into cytogenetic analyses …

Inline diff:

```
Our study highlights the power of integr … w technologies into cytogenetic analyses 〔- [13, 16] -〕 〔+ 13,16 +〕
```

### orig #84 → rev #86

OLD:
> In the first case, a de novo inversion on chromosome 8 that had been deemed a balanced paracentric inversion was revealed to be far more complex. LRS and OGM detected two interstitial deletions flanking an inverted segment on 8p, refining the molecular finding to a cryptic unbalanced inversion-deletion. Notably, one deleted segment (~2.5 Mb) fell within the known 8p23.1 microdeletion region, which is associated with prenatal growth restriction, microcephaly, congenital heart defects, and developmental delay, likely through combined haploinsufficiency of key genes within the interval, including GATA4, SOX7, and TNKS [18]. In our proband, the deleted interval spares GATA4, consistent with the absence of CHD and with prior evidence that GATA4 dosage is the major determinant of the cardiac phe…

NEW:
> In the first case, a de novo inversion on chromosome 8 that had been deemed a balanced paracentric inversion was revealed to be far more complex. LRS and OGM detected two interstitial deletions flanking an inverted segment on 8p, refining the molecular finding to a cryptic unbalanced inversion-deletion. Notably, one deleted segment (~2.5 Mb) fell within the known 8p23.1 microdeletion region, which is associated with prenatal growth restriction, microcephaly, congenital heart defects, and developmental delay, likely through combined haploinsufficiency of key genes within the interval, including GATA4, SOX7, and TNKS 18. In our proband, the deleted interval spares GATA4, consistent with the absence of CHD and with prior evidence that GATA4 dosage is the major determinant of the cardiac pheno…

Inline diff:

```
In the first case, a de novo inversion o … nterval, including GATA4, SOX7, and TNKS 〔- [18]. -〕 〔+ 18. +〕 In our proband, the deleted interval spa … ac phenotype in 8p23.1 deletion syndrome 〔- [18, 19]. -〕 〔+ 18,19. +〕 The genotype-phenotype correlation for m … determinant has not been clearly defined 〔- [18]. -〕 〔+ 18. +〕 Although MCPH1 is a known microcephaly g … aly-related genes were identified in LRS 〔- [27]. -〕 〔+ 27. +〕 In terms of mechanism, the breakpoint an … homology-driven and end-joining pathways 〔- [28, 29]. -〕 〔+ 28,29. +〕 Moreover, 〔- Whereas -〕 〔+ whereas +〕 rearrangements involving the 8p23 region … ions of a relatively fixed size interval 〔- [18], -〕 〔+ 18, +〕 our case illustrates an alternative outc … rsion accompanied by flanking deletions.
```

### orig #85 → rev #87

OLD:
> The second case carried a de novo inversion on chromosome 7 that conventional analysis had deemed balanced and of unclear significance. Our LRS and OGM data mapped the inversion breakpoints and showed that the proximal breakpoint disrupts AUTS2 in intron 2. The identification of this AUTS2 breakpoint establishes a direct genotype-phenotype correlation and supports an AUTS2-related syndrome, characterized by intellectual disability, autism/ADHD features, microcephaly, scoliosis, and craniofacial anomalies [20], resolving a diagnostic odyssey in which prior WES sequencing had been non-informative. This outcome exemplifies how genome-wide structural resolution can reveal pathogenic rearrangements disrupting known disease genes at intronic or intergenic breakpoints that are difficult to recons…

NEW:
> The second case carried a de novo inversion on chromosome 7 that conventional analysis had deemed balanced and of unclear significance. Our LRS and OGM data mapped the inversion breakpoints and showed that the proximal breakpoint disrupts AUTS2 in intron 2. The identification of this AUTS2 breakpoint establishes a direct genotype-phenotype correlation and supports an AUTS2-related syndrome, characterized by intellectual disability, autism/ADHD features, microcephaly, scoliosis, and craniofacial anomalies 20, resolving a diagnostic odyssey in which prior WES sequencing had been non-informative. This outcome exemplifies how genome-wide structural resolution can reveal pathogenic rearrangements disrupting known disease genes at intronic or intergenic breakpoints that are difficult to reconstr…

Inline diff:

```
The second case carried a de novo invers … y, scoliosis, and craniofacial anomalies 〔- [20], -〕 〔+ 20, +〕 resolving a diagnostic odyssey in which  … icult to reconstruct accurately with WES 〔- [15]. -〕 〔+ 15. To verify that the failure of the prior WES was a fundamental assay limitation rather than an artifact of the analysis pipeline, we retrospectively re-analyzed the original WES BAM with two methodologically distinct short-read SV callers — Manta v1.6.0 43 (run with --exome and without restricting --callRegions) and Delly v1.2.6 44 (default parameters) — using the GRCh38 + hs38d1 + HLA reference. Both callers operated normally on chromosome 7 (Manta: 129 candidate SVs; Delly: 142 SV records), yet neither returned any record within a ±50 kb window of either LRS-defined breakpoint, including in Manta's most permissive candidateSV output (Supplementary Table 6). Per-base read depth at the two breakpoints was 0.07× and 0.16×, against 154.81× at a captured positive-control exon (TP53 exon 4) and a median of 106.09× across the 19 captured AUTS2 exons (range 35.90×–274.85×; NM_015570.4) — a more than 1,500-fold deficit relative to the captured AUTS2 exonic baseline. The concordant negative result across two independent callers, together with the near-zero local read depth, demonstrates that the AUTS2 intron 2 breakpoint and its 7q21.3 partner lie outside exome capture territory and are inaccessible to short-read WES at the read level, regardless of the variant caller applied. +〕 Furthermore, breakpoint analysis suggest … t with non-homologous end joining (NHEJ) 〔- [17, 30]. -〕 〔+ 17,30. +〕 Our integrative approach thus turned an  … ubstantial added value for patient care.
```

### orig #86 → rev #88

OLD:
> The third case involved the most complex rearrangement. The patient’s karyotype showed two de novo apparently balanced translocations, t(2;13)(q33;q32) and t(5;7)(q11.2;q32). Our LRS and OGM analyses revealed an underlying multi-chromosomal complex genomic rearrangement, with chromosomes 2, 5, 7 and 13 connected by numerous breakpoints and deletions. In this context, the CNTNAP2-disrupting breakpoint together with the 7q deletion provides a plausible molecular explanation for the patient’s neurodevelopmental phenotype. The shattering and reassembly of segments on multiple chromosomes is reminiscent of chromothripsis or chromoplexy, types of chromoanagenesis characterized by multiple double-strand breaks occurring simultaneously and rejoining in abnormal configurations [28, 31, 32]. The com…

NEW:
> The third case involved the most complex rearrangement. The patient’s karyotype showed two de novo apparently balanced translocations, t(2;13)(q33;q32) and t(5;7)(q11.2;q32). Our LRS and OGM analyses revealed an underlying multi-chromosomal complex genomic rearrangement, with chromosomes 2, 5, 7 and 13 connected by numerous breakpoints and deletions. In this context, the CNTNAP2-disrupting breakpoint together with the 7q deletion provides a plausible molecular explanation for the patient’s neurodevelopmental phenotype. The shattering and reassembly of segments on multiple chromosomes is highly reminiscent of chromoanagenesis — a class of complex genomic rearrangement (CGR) that includes chromothripsis and chromoplexy and is thought to arise from multiple double-strand breaks resolving simu…

Inline diff:

```
The third case involved the most complex … y of segments on multiple chromosomes is 〔+ highly +〕 reminiscent of 〔+ chromoanagenesis — a class of complex genomic rearrangement (CGR) that includes +〕 chromothripsis 〔- or chromoplexy, types of chromoanagenesis characterized by -〕 〔+ and chromoplexy and is thought to arise from +〕 multiple double-strand breaks 〔- occurring -〕 〔+ resolving +〕 simultaneously 〔- and rejoining in -〕 〔+ into +〕 abnormal configurations 〔- [28, 31, 32]. -〕 〔+ 28,30,31,32. Our case fulfils several qualitative hallmarks of chromoanagenesis (clustered breakpoints distributed across two reciprocal exchanges, focal copy-number losses, and inverted orientations within rearranged segments); a formal classification under the chromothripsis criteria of Korbel and Campbell 42 would require additional copy-number oscillation analysis. Importantly, the simultaneous detection of these multiple breakpoints required integrated LRS and OGM, since each platform alone would have under-resolved the rearrangement. +〕 The combination of multiple breakpoints  … ips, leading to deleterious consequences 〔- [8, 31, 32]. -〕 〔+ 8,31,32. +〕 LRS and OGM allowed us to reconstruct th … nstruct complex rearrangements in detail 〔- [17, 33-35]. -〕 〔+ 17,33-35. We acknowledge that the patient harbours both a CNTNAP2-disrupting breakpoint and a co-occurring ~5.4 Mb 7q34–q35 deletion (Figure 3E), which encompasses additional OMIM-listed genes (BRAF, AGK, CLCN1, TBXAS1, WEE2, SSBP1, TAS2R38, PRSS1, PRSS2, TRPV6, KEL, CASP2, NOBOX, TPK1, SLC37A3); with current data we cannot fully partition the contribution of CNTNAP2 disruption versus the contiguous-gene deletion to the proband's neurodevelopmental phenotype, although CNTNAP2 has the strongest a priori evidence for autism-spectrum and language phenotypes 23-26. +〕
```

### orig #87 → rev #89

OLD:
> The comparative performance of LRS and OGM in our study highlights the complementary strengths of these technologies. OGM offered a genome-wide view of large structural changes. Its ultra-long molecules and alignment maps made it possible to reconstruct whole-chromosome architecture and to see how rearranged segments are ordered and oriented, while remaining highly sensitive to balanced and copy-neutral events that can escape traditional sequencing or CMA [13, 16, 36]. LRS further provided comprehensive sequence-level SV detection and single-nucleotide resolution of breakpoint junctions, allowing us to identify affected genes and microhomologies and to infer mutational mechanisms [11, 16]. In our experience, using LRS and OGM together was more powerful than either method alone, because cro…

NEW:
> The comparative performance of LRS and OGM in our study highlights the complementary strengths of these technologies. OGM offered a genome-wide view of large structural changes. Its ultra-long molecules and alignment maps made it possible to reconstruct whole-chromosome architecture and to see how rearranged segments are ordered and oriented, while remaining highly sensitive to balanced and copy-neutral events that can escape traditional sequencing or CMA 13,16,36. LRS further provided comprehensive sequence-level SV detection and single-nucleotide resolution of breakpoint junctions, allowing us to identify affected genes and microhomologies and to infer mutational mechanisms 11,16. In our experience, using LRS and OGM together was more powerful than either method alone, because cross-vali…

Inline diff:

```
The comparative performance of LRS and O … can escape traditional sequencing or CMA 〔- [13, 16, 36]. -〕 〔+ 13,16,36. +〕 LRS further provided comprehensive seque … ogies and to infer mutational mechanisms 〔- [11, 16]. -〕 〔+ 11,16. +〕 In our experience, using LRS and OGM tog … the breakpoints at nucleotide resolution 〔- [11, 13, 16]. -〕 〔+ 11,13,16. +〕 In clinical practice, it will not always … genetic syndromes, as it rapidly detects 〔- copy-number variants, -〕 〔+ CNVs, +〕 balanced rearrangements and mosaic events in a single assay 〔- [13, 36]. -〕 〔+ 13,36. +〕 LRS is better suited when nucleotide-lev … and when simultaneous detection of SNVs, 〔- indels -〕 〔+ indels, +〕 and SVs is desired 〔- [12, 37, 38]. -〕 〔+ 12,37,38. +〕 A pragmatic workflow is to use OGM first … on and the relevant sequence information 〔- [13, 16, 17]. -〕 〔+ 13,16,17. +〕 As throughput increases and costs fall,  … Our results, together with previous work 〔- [15, 16], -〕 〔+ 15,16, +〕 show that combining these approaches pro …  of resolution and certainty for complex 〔- structural variants. -〕 〔+ SVs. We further note that the apparent disparity in raw SV counts between OGM (Table 2) and LRS (Table 3) reflects different size sensitivities and filtering stages rather than a real difference in detection breadth: OGM has a lower size limit of approximately 500 bp and the counts in Table 2 are already population-rarity filtered against the Bionano control database, whereas LRS pbsv calls were enumerated at SVLEN ≥50 bp prior to population filtering. After equivalent rarity filtering, the two platforms returned comparable numbers of high-confidence rare SVs per case (Table 2 versus the population-filtered SV row of Table 3). +〕
```

### orig #88 → rev #90

OLD:
> Our study has several limitations. First, the sample size is small – we analyzed three cases, each with unique rearrangements. While this is typical for a demonstration in rare disease genomics, it limits the generalizability of our conclusions. A larger cohort study would be valuable to determine the true proportion of balanced rearrangements that are reclassified by LRS and OGM [17]. Second, our work was laboratory-intensive. We used comprehensive research-based sequencing and mapping with custom analytical pipelines and expert manual curation, which does not reflect real-world, streamlined clinical workflows at present. Interpretation of complex SVs remains challenging, particularly when discriminating pathogenic events from benign polymorphic variation, and automated pipelines for SV c…

NEW:
> Our study has several limitations. First, the sample size is small – we analyzed three cases, each with unique rearrangements. While this is typical for a demonstration in rare disease genomics, it limits the generalizability of our conclusions. A larger cohort study would be valuable to determine the true proportion of balanced rearrangements that are reclassified by LRS and OGM 17. Second, our work was laboratory-intensive. We used comprehensive research-based sequencing and mapping with custom analytical pipelines and expert manual curation, which does not reflect real-world, streamlined clinical workflows at present. Interpretation of complex SVs remains challenging, particularly when discriminating pathogenic events from benign polymorphic variation, and automated pipelines for SV cla…

Inline diff:

```
Our study has several limitations. First … nts that are reclassified by LRS and OGM 〔- [17]. -〕 〔+ 17. +〕 Second, our work was laboratory-intensiv … for SV classification are still evolving 〔- [13, 39, 40]. -〕 〔+ 13,39,40. +〕 Third, both technologies have intrinsic  … y small variants and low-level mosaicism 〔- [13, 36], -〕 〔+ 13,36, +〕 as demonstrated in Case 3 in which OGM f … nd may miss very large repeat expansions 〔- [12, 37, 41]. -〕 〔+ 12,37,41. +〕 Future refinements of these modalities s …  these barriers are gradually decreasing 〔- [16, 41]. -〕 〔+ 16,41. +〕 Multi-center real-world evaluations will … ncorporated into standard clinical care. 〔+ Fifth, breakpoint junctions and parental trio samples could not be confirmed by Sanger sequencing because the families declined additional blood sampling for personal reasons; we therefore relied on the orthogonal concordance of LRS and OGM (and SNP array, where applicable) as independent lines of evidence supporting the breakpoints and copy-number changes reported here. Future cohorts incorporating routine trio confirmation would further strengthen inference of de novo origin and would exclude rare instances of low-level parental mosaicism. +〕
```

### orig #89 → rev #91

OLD:
> Taken together, our findings support three main implications. First, LRS and OGM uncovered cryptic genomic alterations and breakpoint-level details that were not resolved by karyotyping or microarray, thereby refining genotype-phenotype correlations, providing definitive molecular diagnosis, and ending the diagnostic odyssey, in line with prior studies advocating the incorporation of higher-resolution genomic technologies into cytogenetic evaluation [13, 16]. Second, apparently balanced translocations or inversions may still be pathogenic because they can harbor cryptic imbalances, disrupt dosage-sensitive genes, or alter regulatory architecture despite the absence of visible net chromosomal gain or loss on routine testing [4-8]. Such patients therefore require long-term follow-up and indi…

NEW:
> Taken together, our findings support three main implications. First, LRS and OGM uncovered cryptic genomic alterations and breakpoint-level details that were not resolved by karyotyping or microarray, thereby refining genotype-phenotype correlations, providing a refined molecular characterization that resolves the apparent karyotype as an unbalanced deletion-inversion-deletion event in Case 1 and identifies dosage-sensitive disease genes (the 8p23.1 microdeletion region, AUTS2, CNTNAP2) as the most likely contributors to each proband's phenotype, in line with prior studies advocating the incorporation of higher-resolution genomic technologies into cytogenetic evaluation 13,16. Second, apparently balanced translocations or inversions may still be pathogenic because they can harbor cryptic i…

Inline diff:

```
Taken together, our findings support thr … notype-phenotype correlations, providing 〔- definitive -〕 〔+ a refined +〕 molecular 〔- diagnosis, -〕 〔+ characterization that resolves the apparent karyotype as an unbalanced deletion-inversion-deletion event in Case 1 +〕 and 〔- ending -〕 〔+ identifies dosage-sensitive disease genes (the 8p23.1 microdeletion region, AUTS2, CNTNAP2) as +〕 the 〔- diagnostic odyssey, -〕 〔+ most likely contributors to each proband's phenotype, +〕 in line with prior studies advocating th … technologies into cytogenetic evaluation 〔- [13, 16]. -〕 〔+ 13,16. +〕 Second, apparently balanced translocatio … omosomal gain or loss on routine testing 〔- [4-8]. -〕 〔+ 4-8. +〕 Such patients therefore require long-ter … d detection of gene-disrupting junctions 〔- [12, 16]. -〕 〔+ 12,16. +〕 Accordingly, test selection should be ta …  rearrangement and diagnostic objective.
```

### orig #90 → rev #92

OLD:
> In summary, our study shows that combining LRS and OGM allows precise resolution of complex SVs, uncovering cryptic deletions and gene disruptions that explain their phenotypes, converting ambiguous karyotypic findings into definitive molecular diagnoses, and providing clues to the underlying rearrangement mechanisms. As LRS and OGM continue to mature, we anticipate their routine adoption in genetic diagnostics, bridging the longstanding gap between karyotype and sequence analysis, improving genotype-phenotype correlation and strengthening the basis for clinical counselling.

NEW:
> In summary, our study shows that combining LRS and OGM allows precise resolution of complex SVs, uncovering cryptic deletions and gene disruptions that explain their phenotypes, refining ambiguous karyotypic findings into precise molecular characterizations, and providing clues to the underlying rearrangement mechanisms. As LRS and OGM continue to mature, we anticipate their routine adoption in genetic diagnostics, bridging the longstanding gap between karyotype and sequence analysis, improving genotype-phenotype correlation and strengthening the basis for clinical counselling.

Inline diff:

```
In summary, our study shows that combini … sruptions that explain their phenotypes, 〔- converting -〕 〔+ refining +〕 ambiguous karyotypic findings into 〔- definitive -〕 〔+ precise +〕 molecular 〔- diagnoses, -〕 〔+ characterizations, +〕 and providing clues to the underlying re … ning the basis for clinical counselling.
```

### orig #100 → rev #116

OLD:
> [9] Levy B, Wapner R. Prenatal diagnosis by chromosomal microarray analysis. Fertil Steril. 2018;109:201-12.

NEW:
> 9. Levy, B. & Wapner, R. Prenatal diagnosis by chromosomal microarray analysis. Fertil Steril 109, 201–12 (2018).

Inline diff:

```
〔- [9] Levy B, Wapner -〕 〔+ 9. Levy, B. & Wapner, +〕 R. Prenatal diagnosis by chromosomal microarray analysis. Fertil 〔- Steril. 2018;109:201-12. -〕 〔+ Steril 109, 201–12 (2018). +〕
```

### orig #109 → rev #125

OLD:
> [18] Montenegro MM, Camilotti D, Quaio C, Gasparini Y, Zanardo É A, Rangel-Santos A, et al. Expanding the Phenotype of 8p23.1 Deletion Syndrome: Eight New Cases Resembling the Clinical Spectrum of 22q11.2 Microdeletion. J Pediatr. 2023;252:56-60.e2.

NEW:
> 18 Montenegro MM, Camilotti D, Quaio C, Gasparini Y, Zanardo É A, Rangel-Santos A, et al. Expanding the Phenotype of 8p23.1 Deletion Syndrome: Eight New Cases Resembling the Clinical Spectrum of 22q11.2 Microdeletion. J Pediatr. 2023;252:56-60.e2.

Inline diff:

```
〔- [18] -〕 〔+ 18 +〕 Montenegro MM, Camilotti D, Quaio C, Gas … odeletion. J Pediatr. 2023;252:56-60.e2.
```

### orig #115 → rev #131

OLD:
> [24] Poot M, Beyer V, Schwaab I, Damatova N, Van't Slot R, Prothero J, et al. Disruption of CNTNAP2 and additional structural genome changes in a boy with speech delay and autism spectrum disorder. Neurogenetics. 2010;11:81-9.

NEW:
> 24. Poot, M., Beyer, V., Schwaab, I., Damatova, N., Van't Slot, R. et al. Disruption of CNTNAP2 and additional structural genome changes in a boy with speech delay and autism spectrum disorder. Neurogenetics 11, 81–9 (2010).

Inline diff:

```
〔- [24] Poot M, Beyer V, Schwaab I, Damatova N, -〕 〔+ 24. Poot, M., Beyer, V., Schwaab, I., Damatova, N., +〕 Van't 〔- Slot R, Prothero J, -〕 〔+ Slot, R. +〕 et al. Disruption of CNTNAP2 and additio … eech delay and autism spectrum disorder. 〔- Neurogenetics. 2010;11:81-9. -〕 〔+ Neurogenetics 11, 81–9 (2010). +〕
```

### orig #116 → rev #132

OLD:
> [25] Whitehouse AJ, Bishop DV, Ang QW, Pennell CE, Fisher SE. CNTNAP2 variants affect early language development in the general population. Genes Brain Behav. 2011;10:451-6.

NEW:
> 25. Whitehouse, A.J., Bishop, D.V., Ang, Q.W., Pennell, C.E. & Fisher, S.E. CNTNAP2 variants affect early language development in the general population. Genes Brain Behav 10, 451–6 (2011).

Inline diff:

```
〔- [25] Whitehouse AJ, Bishop DV, Ang QW, Pennell CE, Fisher SE. -〕 〔+ 25. Whitehouse, A.J., Bishop, D.V., Ang, Q.W., Pennell, C.E. & Fisher, S.E. +〕 CNTNAP2 variants affect early language d … t in the general population. Genes Brain 〔- Behav. 2011;10:451-6. -〕 〔+ Behav 10, 451–6 (2011). +〕
```

### orig #127 → rev #143

OLD:
> [36] Yuan Y, Chung CY, Chan TF. Advances in optical mapping for genomic research. Comput Struct Biotechnol J. 2020;18:2051-62.

NEW:
> 36. Yuan, Y., Chung, C.Y. & Chan, T.F. Advances in optical mapping for genomic research. Comput Struct Biotechnol J 18, 2051–62 (2020).

Inline diff:

```
〔- [36] Yuan Y, Chung CY, Chan TF. -〕 〔+ 36. Yuan, Y., Chung, C.Y. & Chan, T.F. +〕 Advances in optical mapping for genomic research. Comput Struct Biotechnol 〔- J. 2020;18:2051-62. -〕 〔+ J 18, 2051–62 (2020). +〕
```

### orig #130 → rev #146

OLD:
> [39] Liu X, Gu L, Hao C, Xu W, Leng F, Zhang P, et al. Systematic assessment of structural variant annotation tools for genomic interpretation. Life Sci Alliance. 2025;8.

NEW:
> 39 Liu X, Gu L, Hao C, Xu W, Leng F, Zhang P, et al. Systematic assessment of structural variant annotation tools for genomic interpretation. Life Sci Alliance. 2025;8.

Inline diff:

```
〔- [39] -〕 〔+ 39 +〕 Liu X, Gu L, Hao C, Xu W, Leng F, Zhang  … terpretation. Life Sci Alliance. 2025;8.
```

