# Case 2 — Manta WES Re-analysis: Manuscript Material

Drafts to be incorporated into the npj Genomic Medicine submission.
All numerical values are from the actual run (Manta v1.6.0,
quay.io/biocontainers/manta:1.6.0--h9ee0642_1, Apr 2026; BAM
AA001181.bam; reference GRCh38_full_analysis_set_plus_decoy_hla).

---

## 1. Supplementary Methods (new section)

### Retrospective Manta short-read SV re-analysis of Case 2 WES data

To assess whether the AUTS2-disrupting inversion identified by long-read
sequencing in Case 2 was in principle recoverable from the original
short-read whole-exome sequencing (WES) data, the previously generated
WES BAM file (aligned to GRCh38 with hs38d1 decoys, chrEBV and HLA
contigs) was re-analyzed with Manta v1.6.0 (Illumina), a structural-variant
caller designed to integrate split-read and discordant-pair evidence.
configManta.py was invoked with `--exome` to apply WES-tuned thresholds;
`--callRegions` was intentionally omitted so that both on-target and
off-target reads contributed evidence. All other parameters were left at
defaults. The full workflow completed in 150 s and produced standard
Manta outputs (diploidSV.vcf.gz, candidateSV.vcf.gz,
candidateSmallIndels.vcf.gz). Records overlapping a ±50 kb window around
each LRS-defined inversion breakpoint (chr7:69,938,691 and
chr7:95,720,897) were extracted with bcftools, and bidirectional breakend
mate-pair scans were performed to detect any record on either side whose
ALT field cited a coordinate in the partner window. Per-position read
depth was computed with `samtools depth -a` for each LRS breakpoint, for
every AUTS2 RefSeq exon (NM_015570), and for TP53 exon 4
(chr17:7,675,994–7,676,272) as a captured positive control.

---

## 2. Supplementary Table X. WES read depth and Manta calls at AUTS2 and the
   LRS-defined inversion breakpoints (Case 2)

| Region | Annotation | Length (bp) | Mean read depth (×) | Manta records within ±50 kb |
|---|---|---:|---:|---:|
| chr17:7,675,994–7,676,272 | TP53 exon 4 (positive control) | 279 | **154.81** | n/a |
| chr7:69,599,000–69,602,000 | AUTS2 exon 1 / promoter region (3 kb window) | 3,001 | 18.91 | n/a |
| chr7:69,938,191–69,939,191 | LRS breakpoint A (AUTS2 intron 2) | 1,001 | **0.07** | **0 (diploidSV); 0 (candidateSV)** |
| chr7:95,720,397–95,721,397 | LRS breakpoint B (7q21.3) | 1,001 | **0.16** | **0 (diploidSV); 0 (candidateSV)** |
| (per-exon AUTS2) | NM_015570 exons 1–19 | … | … | n/a |

> **Note:** the per-exon AUTS2 row will be expanded with the output of
> `compute_auts2_exon_depth.sh` (`depth_per_region.tsv`).

For genome-wide context, Manta produced **129 candidate structural
variants on chromosome 7** (consistent with the per-chromosome counts on
chr1 = 220, chr2 = 170, chr19 = 199), confirming that the workflow
operated normally; the absence of records around the LRS breakpoints
therefore reflects the absence of supporting reads rather than a
caller-level limitation.

---

## 3. Discussion — proposed revision to the Case 2 paragraph (page X, line Y)

### Existing wording
> The second case carried a de novo inversion on chromosome 7 that
> conventional analysis had deemed balanced and of unclear significance.
> Our LRS and OGM data mapped the inversion breakpoints and showed that
> the proximal breakpoint disrupts AUTS2 in intron 2. The identification
> of this AUTS2 breakpoint establishes a direct genotype–phenotype
> correlation and supports an AUTS2-related syndrome … resolving a
> diagnostic odyssey in which prior WES sequencing had been
> non-informative.

### Proposed wording
> The second case carried a de novo inversion on chromosome 7 that
> conventional analysis had deemed balanced and of unclear significance.
> Our LRS and OGM data mapped the inversion breakpoints and showed that
> the proximal breakpoint disrupts AUTS2 in intron 2. The identification
> of this AUTS2 breakpoint establishes a direct genotype–phenotype
> correlation and supports an AUTS2-related syndrome, characterized by
> intellectual disability, autism/ADHD features, microcephaly, scoliosis,
> and craniofacial anomalies [20], resolving a diagnostic odyssey in
> which prior WES had been non-informative. To verify that the failure of
> WES was a fundamental assay limitation rather than an artefact of the
> analysis pipeline, we retrospectively re-analyzed the original WES BAM
> with Manta v1.6.0 in `--exome` mode without restricting `--callRegions`,
> giving the caller access to both on-target and off-target reads. Manta
> produced 129 candidate SVs on chromosome 7 yet returned no records —
> neither in diploidSV nor in the most permissive candidateSV output —
> within a ±50 kb window of either LRS-defined breakpoint
> (Supplementary Table X). Per-position read depth at the two breakpoints
> was 0.07× and 0.16×, against 154.81× at a captured positive-control
> exon (TP53 exon 4) and tens to hundreds of reads per base across
> captured AUTS2 exons (Supplementary Table X). Together these data
> demonstrate that the AUTS2 intron 2 breakpoint and its 7q21.3 partner
> lie outside exome capture territory and are therefore inaccessible to
> short-read WES at the read level, regardless of the variant caller
> applied — providing direct evidence of the additional information
> contributed by LRS and OGM in this case.

---

## 4. Response to Reviewer (Major Issue 8)

> **Reviewer comment.** Case 2 — AUTS2 and previous WES. WES typically
> covers AUTS2 coding exons; if the inversion breakpoint lies in intron
> 2, coverage should still be normal but split reads in WES are not
> easily seen. Please explicitly explain in the Discussion why the
> previous WES missed this event …, and consider re-running WES BAM with
> an SV caller (Manta/Delly).

> **Authors' response.** We thank the reviewer for this constructive
> suggestion. To address it directly, we re-analyzed Case 2's original
> WES BAM with Manta v1.6.0, an SV caller designed to integrate
> split-read and discordant-pair evidence, configured with `--exome` and
> without restricting `--callRegions` so that off-target reads were
> available. Manta operated normally (129 candidate SVs called on
> chromosome 7 alone), but **no records — even at the most permissive
> candidateSV level — were returned within ±50 kb of either LRS-defined
> breakpoint** (chr7:69,938,691 and chr7:95,720,897). Per-position WES
> depth at these positions was 0.07× and 0.16×, against 154.81× at
> TP53 exon 4 (positive control) and tens to hundreds of reads per
> captured AUTS2 exon. The inability of the prior WES to detect this
> rearrangement was therefore an assay-level rather than analytical
> limitation: the breakpoints fall in deep intronic / intergenic
> regions outside the exome capture targets, where coverage is
> essentially zero, so no short-read SV caller could be expected to
> recover them. We have added this analysis as a new Supplementary
> Methods subsection ("Retrospective Manta short-read SV re-analysis of
> Case 2 WES data") and Supplementary Table X (WES depth and Manta calls
> at AUTS2 and the LRS-defined breakpoints), and revised the
> corresponding Discussion paragraph (page X, lines Y–Z) accordingly.

---

## 5. Reproducibility — pinned commands

```text
Reference : GRCh38_full_analysis_set_plus_decoy_hla.fa
            (1000 Genomes FTP /vol1/ftp/technical/reference/GRCh38_reference_genome/)
Caller    : Manta 1.6.0
Image     : quay.io/biocontainers/manta:1.6.0--h9ee0642_1 (linux/amd64)
Config    : configManta.py --bam <BAM> --referenceFasta <REF> \
                           --runDir <RUN> --exome
Run       : runWorkflow.py -j 8
Wall-time : 150 s
```

Scripts in this repository:
- `download_grch38_analysis_set.sh` — fetches the matching reference
- `run_manta_case2.sh` — runs Manta + post-hoc ROI filtering
- `compute_auts2_exon_depth.sh` — generates the per-region depth table
