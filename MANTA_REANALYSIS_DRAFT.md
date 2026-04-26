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

All coordinates GRCh38; AUTS2 transcript NM_015570.4. Depth is mean
per-base coverage from `samtools depth -a` of the original WES BAM.
Manta records were enumerated from `diploidSV.vcf.gz` and
`candidateSV.vcf.gz` within a ±50 kb window of each LRS breakpoint.

| # | Region (1-based) | Annotation | Length (bp) | Mean depth (×) | Manta records (diploidSV / candidateSV) |
|---|---|---|---:|---:|---:|
| – | chr17:7,675,995–7,676,272 | TP53 exon 4 (positive control) | 278 | 154.81 | n/a |
| 1 | chr7:69,598,475–69,599,962 | AUTS2 exon 1 (5′ UTR + start) | 1,488 | 35.90 | n/a |
| 2 | chr7:69,899,286–69,899,498 | AUTS2 exon 2 | 213 | 274.85 | n/a |
| 3 | chr7:70,118,132–70,118,233 | AUTS2 exon 3 | 102 | 110.64 | n/a |
| 4 | chr7:70,134,536–70,134,571 | AUTS2 exon 4 | 36 | 160.83 | n/a |
| 5 | chr7:70,435,752–70,435,781 | AUTS2 exon 5 | 30 | 103.77 | n/a |
| 6 | chr7:70,698,569–70,698,620 | AUTS2 exon 6 | 52 | 100.29 | n/a |
| 7 | chr7:70,762,870–70,763,341 | AUTS2 exon 7 | 472 | 195.63 | n/a |
| 8 | chr7:70,764,752–70,765,005 | AUTS2 exon 8 | 254 | 105.28 | n/a |
| 9 | chr7:70,766,114–70,766,334 | AUTS2 exon 9 | 221 | 228.38 | n/a |
| 10 | chr7:70,768,024–70,768,068 | AUTS2 exon 10 | 45 | 63.27 | n/a |
| 11 | chr7:70,771,549–70,771,644 | AUTS2 exon 11 | 96 | 106.09 | n/a |
| 12 | chr7:70,774,028–70,774,099 | AUTS2 exon 12 | 72 | 165.08 | n/a |
| 13 | chr7:70,775,357–70,775,386 | AUTS2 exon 13 | 30 | 123.83 | n/a |
| 14 | chr7:70,777,103–70,777,174 | AUTS2 exon 14 | 72 | 91.78 | n/a |
| 15 | chr7:70,781,615–70,781,756 | AUTS2 exon 15 | 142 | 236.77 | n/a |
| 16 | chr7:70,784,942–70,785,019 | AUTS2 exon 16 | 78 | 91.26 | n/a |
| 17 | chr7:70,785,955–70,786,038 | AUTS2 exon 17 | 84 | 95.80 | n/a |
| 18 | chr7:70,787,209–70,787,431 | AUTS2 exon 18 | 223 | 168.65 | n/a |
| 19 | chr7:70,789,748–70,793,506 | AUTS2 exon 19 (CDS + 3′ UTR) | 3,759 | 64.74 | n/a |
| – | chr7:69,938,192–69,939,191 | **LRS breakpoint A (AUTS2 intron 2, ±500 bp)** | 1,000 | **0.07** | **0 / 0** |
| – | chr7:95,720,398–95,721,397 | **LRS breakpoint B (7q21.3, ±500 bp)** | 1,000 | **0.16** | **0 / 0** |

Across the 19 captured AUTS2 exons, mean depth ranged from 35.90× to
274.85× (median 106.09×, mean 132.78×). The two LRS-defined breakpoints
were covered at 0.07× and 0.16× — **more than 1,500-fold and 660-fold
lower than the median captured AUTS2 exon, and >900-fold lower than the
TP53 positive control**. For genome-wide context, Manta produced 129
candidate structural variants on chromosome 7 (consistent with
per-chromosome counts of chr1 = 220, chr2 = 170, chr19 = 199),
confirming that the workflow itself operated normally; the absence of
records around the LRS breakpoints therefore reflects the absence of
supporting reads rather than a caller-level limitation.

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
> with two methodologically distinct short-read SV callers — Manta v1.6.0
> (run with `--exome` and without restricting `--callRegions`, so that
> off-target reads were available) and Delly v1.2.6 (default parameters)
> — using the same GRCh38 + hs38d1 + HLA reference. Both callers
> operated normally on chromosome 7 (Manta: 129 candidate SVs; Delly:
> 142 records), yet neither returned **any** record within a ±50 kb
> window of either LRS-defined breakpoint, including in Manta's most
> permissive candidateSV output (Supplementary Table X). Per-position
> read depth at the two breakpoints was 0.07× and 0.16×, against 154.81×
> at a captured positive-control exon (TP53 exon 4) and a median of
> 106.09× across the 19 captured AUTS2 exons (range 35.90×–274.85×;
> NM_015570.4; Supplementary Table X) — a more than 1,500-fold deficit
> of coverage at the AUTS2 intron 2 breakpoint relative to the captured
> AUTS2 exonic baseline. The concordant negative result across two
> independent callers, together with the near-zero local read depth,
> demonstrates that the AUTS2 intron 2 breakpoint and its 7q21.3 partner
> lie outside exome capture territory and are therefore inaccessible to
> short-read WES at the read level — providing direct evidence of the
> additional information contributed by LRS and OGM in this case.

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
> WES BAM with **two methodologically distinct short-read SV callers —
> Manta v1.6.0 and Delly v1.2.6** — both designed to integrate
> split-read and discordant-pair evidence. Manta was configured with
> `--exome` and without restricting `--callRegions` so that off-target
> reads were available; Delly was run with default parameters. Both
> callers operated normally on chromosome 7 (Manta: 129 candidate SVs;
> Delly: 142 SV records), but **neither returned any record within ±50
> kb of either LRS-defined breakpoint** (chr7:69,938,691 and
> chr7:95,720,897), including at Manta's most permissive candidateSV
> level. Per-position WES depth at these positions was 0.07× and 0.16×,
> against 154.81× at TP53 exon 4 (positive control) and a median of
> 106.09× (range 35.90×–274.85×) across the 19 captured AUTS2 exons
> (NM_015570.4) — a >1,500-fold coverage deficit at the AUTS2 intron 2
> breakpoint relative to the captured AUTS2 exonic baseline. The
> concordant negative result across two independent callers establishes
> that the inability of prior WES to detect this rearrangement was an
> assay-level rather than analytical limitation: the breakpoints fall
> in deep intronic / intergenic regions outside the exome capture
> targets, where coverage is essentially zero, so no short-read SV
> caller could be expected to recover them. We have added this analysis
> as new Supplementary Methods subsections ("Retrospective Manta
> short-read SV re-analysis of Case 2 WES data" and "Independent caller
> verification with Delly") and Supplementary Table X (WES depth and
> Manta + Delly calls at AUTS2 and the LRS-defined breakpoints), and
> revised the corresponding Discussion paragraph (page X, lines Y–Z)
> accordingly.

---

## 5. Supplementary Figure proposal — IGV coverage comparison

A four-panel Supplementary Figure visualises the read-level basis for the
"assay-level rather than analytical" conclusion. Generated with an IGV
batch script (`igv_screenshots.batch`) for full reproducibility.

### Figure layout

| Panel | Locus (GRCh38) | Annotation | Expected appearance |
|---|---|---|---|
| **A** | chr17:7,675,500–7,676,800 | TP53 exon 4 (positive control) | Tall, uniform pile-up of paired reads (~155×) |
| **B** | chr7:69,898,800–69,900,000 | AUTS2 exon 2 (captured) | Tall pile-up (~275×) |
| **C** | chr7:69,933,691–69,943,691 | AUTS2 intron 2 LRS breakpoint, ±5 kb | Essentially blank coverage track (~0.07×); centre marker at chr7:69,938,691 |
| **D** | chr7:95,715,897–95,725,897 | 7q21.3 LRS breakpoint, ±5 kb | Essentially blank coverage track (~0.16×); centre marker at chr7:95,720,897 |
| (E) | chr7:69,598,000–70,794,000 | Optional gene-wide AUTS2 view | Discrete exonic coverage spikes separated by zero-coverage introns |

### Suggested figure caption

> **Supplementary Figure Y. WES read-level coverage at the LRS-defined Case 2
> inversion breakpoints versus captured exonic controls.** Integrative
> Genomics Viewer (IGV v2.x) snapshots from the original Case 2 WES BAM
> aligned to GRCh38 + hs38d1 decoys + HLA contigs. (**A**) TP53 exon 4
> (chr17:7,675,994–7,676,272), a ubiquitously captured positive-control
> exon, showing 154.81× mean read depth. (**B**) AUTS2 exon 2
> (chr7:69,899,286–69,899,498), a captured AUTS2 exon, showing 274.85×
> mean depth. (**C**) The AUTS2 intron 2 LRS-defined breakpoint
> (chr7:69,938,691, red marker) shown with ±5 kb of flanking sequence;
> mean depth across the central 1 kb is 0.07×. (**D**) The 7q21.3
> LRS-defined breakpoint partner (chr7:95,720,897, red marker) shown
> with ±5 kb of flanking sequence; mean depth across the central 1 kb is
> 0.16×. The contrast illustrates that the inversion breakpoints fall
> outside exome capture territory and are therefore inaccessible to
> short-read WES at the read level, regardless of variant caller.

### How to generate (macOS)

```bash
# 1. One-time install (cask is "igv-desktop", not "igv")
brew install --cask igv-desktop

# 2. Make output directory
mkdir -p /Users/changym/Desktop/LR_WGS/Case2/WES/Manta/igv

# 3. Locate the IGV binary (the cask installs as IGV_<version>.app, not
#    plain IGV.app, so we resolve the path dynamically):
IGV_BIN=$(ls -d /Applications/IGV*.app 2>/dev/null \
              | sort -V | tail -1)/Contents/MacOS/IGV

# 4. Run the batch script
"$IGV_BIN" -b ./igv_screenshots.batch

# Alternative if the binary path differs in your IGV version:
#   Open IGV.app -> Tools -> Run Batch Script... -> select igv_screenshots.batch
```

For higher-resolution / publication-grade output, open IGV Desktop
manually, set Preferences → Tracks → Track Height to 250 px and
File → Save SVG/Image at each coordinate. **IGV-Web**
(<https://igv.org/app/>) also works for one-off screenshots without
installing anything: load the BAM via the file picker, paste each
coordinate into the search bar, and use the camera-icon "Save image"
button.

---

## 6. Independent caller verification with Delly

To address the residual concern that the negative Manta result might
reflect Manta-specific behaviour rather than a true absence of evidence,
we additionally re-analyzed the Case 2 WES BAM with Delly v1.2.6
(`dellytools/delly:v1.2.6`), an independently developed structural-variant
caller that combines paired-end and split-read evidence (Rausch et al.,
Bioinformatics 2012). Delly was run with default parameters
(`delly call -g <REF> -o <OUT.bcf> <BAM>`), with the same reference
(GRCh38 + hs38d1 + HLA) and without an exclude list. SV records within
±50 kb of either LRS-defined breakpoint were enumerated, and INFO/CHR2
and INFO/END fields were inspected for any pair joining the two breakpoint
windows.

**Results.** Delly produced **2,922 SV records genome-wide**, including
**142 records on chromosome 7** (comparable to chr1 = 153, chr2 = 226,
chr19 = 325). Despite this dense calling, **0 records fell within the
±50 kb window of chr7:69,938,691 (AUTS2 intron 2)** and **0 records
within the ±50 kb window of chr7:95,720,897 (7q21.3)**. The
bidirectional mate-pair scan returned no record on either side whose
INFO/CHR2 + INFO/END or BND ALT cited a coordinate in the partner
window. Delly's negative result therefore exactly corroborates Manta's
across both breakpoint windows.

**Combined Manta + Delly summary**

| Caller | Version | chr7 SV records | Records in ±50 kb of chr7:69,938,691 | Records in ±50 kb of chr7:95,720,897 | Reciprocal mate-pair |
|---|---|---:|---:|---:|---:|
| Manta  | 1.6.0  | 129 (candidateSV) | 0 | 0 | 0 |
| Delly  | 1.2.6  | 142              | 0 | 0 | 0 |

The concordant negative result across two methodologically distinct
callers confirms that the absence of evidence reflects the underlying
read distribution at the breakpoints (mean depth 0.07× and 0.16×;
Supplementary Table X) rather than caller-specific behaviour.

---

## 7. Reproducibility — pinned commands

```text
Reference : GRCh38_full_analysis_set_plus_decoy_hla.fa
            (1000 Genomes FTP /vol1/ftp/technical/reference/GRCh38_reference_genome/)
Manta     : 1.6.0   image quay.io/biocontainers/manta:1.6.0--h9ee0642_1
            configManta.py --bam <BAM> --referenceFasta <REF> --runDir <RUN> --exome
            runWorkflow.py -j 8                 wall-time 150 s
Delly     : 1.2.6   image dellytools/delly:v1.2.6
            delly call -g <REF> -o <OUT.bcf> <BAM>
            Total SVs 2,922 ; chr7 142 ; ROI 0   wall-time ~10 min
IGV       : 2.19.5  cask igv-desktop
            <IGV.app>/Contents/MacOS/IGV -b igv_screenshots.batch
```

Scripts in this repository:
- `download_grch38_analysis_set.sh` — fetches the matching reference
- `run_manta_case2.sh` — runs Manta + post-hoc ROI filtering
- `run_delly_case2.sh` — runs Delly + post-hoc ROI filtering
- `compute_auts2_exon_depth.sh` — generates the per-region depth table
- `igv_screenshots.batch` — IGV batch script for the supplementary figure
