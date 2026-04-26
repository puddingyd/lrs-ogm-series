#!/usr/bin/env python3
"""revise_manuscript.py — reviewer-driven revision of the LRS+OGM manuscript.

Reads:  LRS_OGM series 2026026.docx
Writes: LRS_OGM_series_2026026_revised.docx
"""
import re
import docx
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import docx.text.paragraph

INPUT = 'LRS_OGM series 2026026.docx'
OUTPUT = 'LRS_OGM_series_2026026_revised.docx'

doc = docx.Document(INPUT)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def replace_in_para(para, old, new, n=1):
    """Replace occurrences of old in para. Edits within a single run when
    possible to preserve italics/bold; otherwise rewrites first run text."""
    if old not in para.text:
        return False
    # Single-run match
    for run in para.runs:
        if old in run.text:
            run.text = run.text.replace(old, new, 1)
            return True
    # Cross-run: rebuild
    if para.runs:
        new_text = para.text.replace(old, new, n)
        para.runs[0].text = new_text
        for r in para.runs[1:]:
            r.text = ''
    return True

def replace_all_in_doc(old, new):
    """Replace old → new in every paragraph."""
    count = 0
    for p in doc.paragraphs:
        if old in p.text:
            replace_in_para(p, old, new)
            count += 1
    return count

def find_para(prefix):
    for p in doc.paragraphs:
        if p.text.startswith(prefix):
            return p
    return None

def find_para_contains(substr):
    for p in doc.paragraphs:
        if substr in p.text:
            return p
    return None

def insert_para_after(anchor, text='', style='Normal'):
    new_p = OxmlElement('w:p')
    anchor._element.addnext(new_p)
    np = docx.text.paragraph.Paragraph(new_p, anchor._parent)
    try:
        np.style = doc.styles[style]
    except Exception:
        pass
    if text:
        np.add_run(text)
    return np

def insert_para_before(anchor, text='', style='Normal'):
    new_p = OxmlElement('w:p')
    anchor._element.addprevious(new_p)
    np = docx.text.paragraph.Paragraph(new_p, anchor._parent)
    try:
        np.style = doc.styles[style]
    except Exception:
        pass
    if text:
        np.add_run(text)
    return np

def insert_paras_after(anchor, items):
    """Insert multiple paragraphs in order after anchor.
    items is list of (text, style)."""
    last = anchor
    for text, style in items:
        last = insert_para_after(last, text, style)
    return last

print('Loaded:', INPUT, '|', len(doc.paragraphs), 'paragraphs')

# ===========================================================================
# Step 1. Simple text fixes (typos, single-token edits)
# ===========================================================================
# UMWH → UHMW
replace_all_in_doc('UMWH gDNA', 'UHMW gDNA')

# DLE-1 motif palindromic note
replace_all_in_doc(
    'specifically targeting the sequence motif CTTAAG within the DNA',
    'specifically targeting the palindromic sequence motif CTTAAG (recognized on both strands of the DNA)'
)

# "tract" → "track" in figure legends
replace_all_in_doc('upper tract', 'upper track')
replace_all_in_doc('middle tract', 'middle track')
replace_all_in_doc('lower tract', 'lower track')
replace_all_in_doc('(upper tract)', '(upper track)')

# Figure 3D coordinate fix (chr7:69.9 Mb is wrong, should be chr7:139 Mb)
replace_all_in_doc('chr7:69.9 Mb (upper track)', 'chr7:139 Mb (upper track)')

# Discussion: capital "Whereas" inside sentence
replace_all_in_doc('Moreover, Whereas rearrangements', 'Moreover, whereas rearrangements')

# Section numbering: 3.3 Case 2 → 3.2 Case 2
p = find_para('3.3 Case 2')
if p:
    replace_in_para(p, '3.3 Case 2', '3.2 Case 2')

# Bayley-III scores for Case 3 (per user: 75 / 65 / 79)
replace_all_in_doc('(Cognitive 65, Language 56, Motor 61)',
                   '(Cognitive 75, Language 65, Motor 79)')

# Note: the same string appears twice in the original (Case 1 + Case 3 typo).
# We need only the Case 3 one fixed; the Case 1 one stays at 65/56/61.
# But replace_all_in_doc replaced ALL — including Case 1. We need to undo Case 1.
# Re-find Case 1 paragraph and revert it.
p_case1 = find_para('The proband is a 4-year-old girl')
if p_case1 and '(Cognitive 75, Language 65, Motor 79)' in p_case1.text:
    replace_in_para(p_case1, '(Cognitive 75, Language 65, Motor 79)',
                              '(Cognitive 65, Language 56, Motor 61)')

# Recruitment dates / cohort source in §2.1
p21 = find_para('We enrolled three unrelated probands')
if p21:
    replace_in_para(p21,
        'Eligible patients were identified by their neurologists or clinical geneticists and recruited consecutively.',
        'Eligible probands were recruited consecutively at National Cheng Kung University Hospital between March 2023 and October 2024 (enrolment dates: 2 March 2023, 9 March 2023, and 21 October 2024) by referral from their attending neurologists or clinical geneticists.')

print('Step 1 (typos / simple fixes): done')

doc.save(OUTPUT)
print('Intermediate save:', OUTPUT)

# Re-load to make sure we work on the latest state if re-running incrementally.
# (When we run in one shot this is harmless.)

# ===========================================================================
# Step 2. Author / corresponding author block
# ===========================================================================
# Original block: para 8 "Corresponding Author:", 9 "Pao-Lin Kuo, ...", 10 "E-mail: paolinkuo@gmail.com"
# Replace with two corresponding authors: Yen-Yin Chou (lead) + Pao-Lin Kuo

p_corr_label = find_para('Corresponding Author')
if p_corr_label:
    replace_in_para(p_corr_label, 'Corresponding Author:', 'Corresponding authors:')

p_paolin = find_para('Pao-Lin Kuo, Department')
p_email = find_para('E-mail: paolinkuo')

if p_paolin:
    # Convert this line to: lead corresponding (Yen-Yin Chou)
    p_paolin.runs[0].text = ''
    for r in p_paolin.runs[1:]:
        r.text = ''
    p_paolin.runs[0].text = ('Yen-Yin Chou (lead corresponding author), Department of Genomic Medicine and '
                              'Department of Pediatrics, National Cheng Kung University Hospital, '
                              '138 Sheng-Li Road, Tainan 704, Taiwan. E-mail: yenyin01@gmail.com')

if p_email:
    p_email.runs[0].text = ('Pao-Lin Kuo, Department of Obstetrics and Gynecology, '
                             'National Cheng Kung University Hospital, '
                             '138 Sheng-Li Road, Tainan 704, Taiwan. E-mail: paolinkuo@gmail.com')
    for r in p_email.runs[1:]:
        r.text = ''

# ===========================================================================
# Step 3. Abstract — insert before "1. Introduction"
# ===========================================================================
p_intro = find_para('1. Introduction')
if p_intro:
    abstract_heading = insert_para_before(p_intro, 'Abstract', style='Heading 2')
    abstract_body = ('Apparently balanced chromosomal rearrangements identified by '
        'karyotyping are increasingly recognised in neurodevelopmental disorders '
        '(NDDs), but their pathogenicity is often underestimated because conventional '
        'cytogenetics and chromosomal microarray cannot resolve cryptic imbalances '
        'or define breakpoint context. We applied integrated long-read sequencing '
        '(LRS) and optical genome mapping (OGM) to three unrelated probands with '
        'NDDs whose prenatal or postnatal karyotype showed an apparently balanced '
        'inversion or reciprocal translocation. In Case 1, a prenatally reported '
        'inv(8)(p23p11.2) was refined into a deletion–inversion–deletion event '
        'within the 8p23.1 microdeletion region, with breakpoints supporting a '
        'two-step mechanism combining REPD/REPP-mediated non-allelic homologous '
        'recombination and microhomology-mediated end joining. In Case 2, an '
        'inv(7)(q11.21q22) disrupted AUTS2 in intron 2, providing a molecular '
        'diagnosis of AUTS2-related syndrome that prior whole-exome sequencing '
        'had been unable to detect; retrospective short-read SV calling with Manta '
        'and Delly on the same WES BAM confirmed that this breakpoint was '
        'unreachable at the read level (mean depth 0.07× versus a median of '
        '106× across captured AUTS2 exons). In Case 3, two apparently balanced '
        'translocations were resolved into a multi-chromosomal complex genomic '
        'rearrangement involving chromosomes 2, 5, 7 and 13, with disruption of '
        'CNTNAP2 plausibly contributing to the autism/ADHD phenotype. Together, '
        'these cases demonstrate that combining LRS and OGM converts apparently '
        'balanced karyotypes into precise molecular diagnoses, exposes cryptic '
        'pathogenic events that escape conventional testing, and clarifies the '
        'mechanisms underlying complex constitutional rearrangements.')
    insert_para_after(abstract_heading, abstract_body, style='Normal')

# ===========================================================================
# Step 4. §2.5.2 / §2.6.2 — methods additions (HiFiCNV + SNV pipeline)
# ===========================================================================
# Methods §2.6.2 paragraph 2 (about pbmm2/pbsv/DeepVariant): add HiFiCNV
p_align = find_para('For alignment, HiFi reads were mapped')
if p_align:
    # Insert HiFiCNV mention after pbsv calling sentence
    replace_in_para(p_align,
        'SVs were called with pbsv (v2.10.0) using default analysis parameters.',
        'SVs were called with pbsv (v2.10.0) using default analysis parameters. '
        'Copy-number variants were called with HiFiCNV (v1.0.1) using default '
        'parameters and the recommended GRCh38 exclude-region BED supplied with '
        'the tool, with sex automatically inferred from chromosome X / Y depth.')

# Methods §2.6.2 paragraph 3 (downstream interpretation): expand SNV pipeline
p_downstream = find_para('For downstream interpretation, CNVs and SVs')
if p_downstream:
    p_downstream.runs[0].text = ''
    for r in p_downstream.runs[1:]:
        r.text = ''
    p_downstream.runs[0].text = (
        'For downstream interpretation, CNVs and SVs were annotated and prioritised '
        'using AnnotSV (https://www.lbgi.fr/AnnotSV/), while SNVs and indels were '
        'annotated with the latest releases of Ensembl Variant Effect Predictor '
        '(VEP) and ANNOVAR. Population allele frequencies were obtained from gnomAD '
        'v4.1, and clinical assertions from ClinVar (release 2025-12-08). Variants '
        'with allele frequency ≥0.01 in gnomAD (any population) were excluded as '
        'common. Functional impact was further assessed using AlphaMissense for '
        'missense variants, MetaRNN as a meta-predictor of pathogenicity, and '
        'SpliceAI for predicted splicing effects. The remaining variants were '
        'classified following the ACMG/AMP guideline. Breakpoints and copy-number '
        'changes were manually reviewed in IGV, and structural variant architecture '
        'and read-level configurations were further assessed using Ribbon '
        '(https://v2.genomeribbon.com/). The filtering and prioritisation workflows '
        'for HiFiCNV-derived CNVs and pbsv-derived SVs are summarised in '
        'Supplementary Tables 4 and 5, respectively.')

print('Step 2-4 (authors / abstract / methods): done')
doc.save(OUTPUT)
print('Saved:', OUTPUT)

# ===========================================================================
# Step 5. Results §3.1 — note about Case 1 OGM CNV bias
# ===========================================================================
p_ogm_case1 = find_para('OGM, however, identified fusion calls linking 8p23.1')
if p_ogm_case1:
    # Append a sentence at the end of this paragraph
    if 'OGM CNV counts in Case 1 were elevated' not in p_ogm_case1.text:
        # Add to last run preserving formatting
        extra = (' We note that the genome-wide OGM CNV count in Case 1 was '
                 'elevated owing to systematic coverage bias (Supplementary '
                 'Table 1); the two true 8p deletions described above were '
                 'nevertheless concordantly detected by OGM, LRS, and SNP '
                 'array (Figure 1B–E), so the conclusions in Case 1 are not '
                 'affected by this bias.')
        # Append to last run
        p_ogm_case1.runs[-1].text = p_ogm_case1.runs[-1].text + extra

# ===========================================================================
# Step 6. Figure 1G dual reference within same paragraph
# ===========================================================================
# Original passage: "...REPP and REPD as the source of the inversion (Figure 1G).
# Sequence inspection of the remaining two junctions ...consistent with
# microhomology-mediated end-joining (MMEJ)(Figure 1G)."
# Merge to a single (Figure 1G) at end.
p_mech = find_para('Breakpoint-level analysis provided insight')
if p_mech:
    replace_in_para(p_mech,
        'as the source of the inversion (Figure 1G).',
        'as the source of the inversion.')
    replace_in_para(p_mech,
        'compatible with microhomology-mediated end-joining (MMEJ)(Figure 1G).',
        'compatible with microhomology-mediated end-joining (MMEJ); the proposed mechanism is summarised in Figure 1G.')

# ===========================================================================
# Step 7. Discussion — Case 3 chromoanagenesis softening
# ===========================================================================
# Find the Discussion paragraph for Case 3 and replace the chromoanagenesis sentence
p_disc_case3 = find_para_contains('two de novo apparently balanced translocations')
if p_disc_case3:
    replace_in_para(p_disc_case3,
        'The shattering and reassembly of segments on multiple chromosomes is reminiscent of chromothripsis or chromoplexy, types of chromoanagenesis characterized by multiple double-strand breaks occurring simultaneously and rejoining in abnormal configurations [28, 31, 32].',
        'The shattering and reassembly of segments on multiple chromosomes is highly reminiscent of chromoanagenesis — a class of complex genomic rearrangement (CGR) that includes chromothripsis and chromoplexy and is thought to arise from multiple double-strand breaks resolving simultaneously into abnormal configurations [28, 30, 31, 32]. Our case fulfils several qualitative hallmarks of chromoanagenesis (clustered breakpoints distributed across two reciprocal exchanges, focal copy-number losses, and inverted orientations within rearranged segments); a formal classification under the chromothripsis criteria of Korbel and Campbell [REF_KORBEL] would require additional copy-number oscillation analysis. Importantly, the simultaneous detection of these multiple breakpoints required integrated LRS and OGM, since each platform alone would have under-resolved the rearrangement.')

# ===========================================================================
# Step 8. Discussion — Case 3 CNTNAP2 vs 7q deletion contribution
# ===========================================================================
# Append a sentence to the Case 3 discussion paragraph about deletion content
if p_disc_case3:
    extra_case3 = (' We acknowledge that the patient harbours both a CNTNAP2-disrupting '
                   'breakpoint and a co-occurring ~5.4 Mb 7q34–q35 deletion (Figure 3E), '
                   'which encompasses additional OMIM-listed genes (BRAF, AGK, CLCN1, '
                   'TBXAS1, WEE2, SSBP1, TAS2R38, PRSS1, PRSS2, TRPV6, KEL, CASP2, '
                   'NOBOX, TPK1, SLC37A3); with current data we cannot fully partition '
                   'the contribution of CNTNAP2 disruption versus the contiguous-gene '
                   'deletion to the proband\'s neurodevelopmental phenotype, although '
                   'CNTNAP2 has the strongest a priori evidence for autism-spectrum '
                   'and language phenotypes [23-26].')
    p_disc_case3.runs[-1].text = p_disc_case3.runs[-1].text + extra_case3

# ===========================================================================
# Step 9. Discussion — Case 2 retrospective Manta + Delly re-analysis
# ===========================================================================
p_disc_case2 = find_para_contains('The second case carried a de novo inversion on chromosome 7')
if p_disc_case2:
    replace_in_para(p_disc_case2,
        'This outcome exemplifies how genome-wide structural resolution can reveal pathogenic rearrangements disrupting known disease genes at intronic or intergenic breakpoints that are difficult to reconstruct accurately with WES [15].',
        'This outcome exemplifies how genome-wide structural resolution can reveal pathogenic rearrangements disrupting known disease genes at intronic or intergenic breakpoints that are difficult to reconstruct accurately with WES [15]. To verify that the failure of the prior WES was a fundamental assay limitation rather than an artefact of the analysis pipeline, we retrospectively re-analysed the original WES BAM with two methodologically distinct short-read SV callers — Manta v1.6.0 [REF_MANTA] (run with --exome and without restricting --callRegions) and Delly v1.2.6 [REF_DELLY] (default parameters) — using the GRCh38 + hs38d1 + HLA reference. Both callers operated normally on chromosome 7 (Manta: 129 candidate SVs; Delly: 142 SV records), yet neither returned any record within a ±50 kb window of either LRS-defined breakpoint, including in Manta\'s most permissive candidateSV output (Supplementary Table 6). Per-base read depth at the two breakpoints was 0.07× and 0.16×, against 154.81× at a captured positive-control exon (TP53 exon 4) and a median of 106.09× across the 19 captured AUTS2 exons (range 35.90×–274.85×; NM_015570.4) — a more than 1,500-fold deficit relative to the captured AUTS2 exonic baseline. The concordant negative result across two independent callers, together with the near-zero local read depth, demonstrates that the AUTS2 intron 2 breakpoint and its 7q21.3 partner lie outside exome capture territory and are inaccessible to short-read WES at the read level, regardless of the variant caller applied.')

# ===========================================================================
# Step 10. Discussion — comparative table 2 vs table 3 sensitivity note
# ===========================================================================
p_compare = find_para_contains('comparative performance of LRS and OGM')
if p_compare:
    extra_cmp = (' We further note that the apparent disparity in raw SV counts '
                 'between OGM (Table 2) and LRS (Table 3) reflects different size '
                 'sensitivities and filtering stages rather than a real difference '
                 'in detection breadth: OGM has a lower size limit of approximately '
                 '500 bp and the counts in Table 2 are already population-rarity '
                 'filtered against the Bionano control database, whereas LRS pbsv '
                 'calls were enumerated at SVLEN ≥50 bp prior to population '
                 'filtering. After equivalent rarity filtering, the two platforms '
                 'returned comparable numbers of high-confidence rare SVs per case '
                 '(Table 2 versus the population-filtered SV row of Table 3).')
    p_compare.runs[-1].text = p_compare.runs[-1].text + extra_cmp

print('Step 5-10 (results / discussion edits): done')
doc.save(OUTPUT)
print('Saved:', OUTPUT)

# ===========================================================================
# Step 11. Discussion — limitations: add Sanger/trio caveat
# ===========================================================================
p_lim = find_para('Our study has several limitations.')
if p_lim:
    extra_lim = (' Fifth, breakpoint junctions and parental trio samples could not be '
                 'confirmed by Sanger sequencing because the families declined '
                 'additional blood sampling for personal reasons; we therefore '
                 'relied on the orthogonal concordance of LRS and OGM (and SNP '
                 'array, where applicable) as independent lines of evidence '
                 'supporting the breakpoints and copy-number changes reported '
                 'here. Future cohorts incorporating routine trio confirmation '
                 'would further strengthen inference of de novo origin and would '
                 'exclude rare instances of low-level parental mosaicism.')
    # append to last run of paragraph
    p_lim.runs[-1].text = p_lim.runs[-1].text + extra_lim

# ===========================================================================
# Step 12. Conclusion + abstract softening for Case 1 (Major #9 upper)
# ===========================================================================
# Look for "conclusive molecular diagnosis" or similar in summary paragraph
replace_all_in_doc(
    'converting ambiguous karyotypic findings into definitive molecular diagnoses',
    'refining ambiguous karyotypic findings into precise molecular characterisations'
)
# In summary "supporting previous calls" sentence
replace_all_in_doc(
    'transform an initially "balanced" finding into a conclusive molecular diagnosis',
    'transform an initially "balanced" finding into a precise molecular characterisation'
)
# Discussion implications paragraph: soften "definitive molecular diagnosis"
replace_all_in_doc(
    'providing definitive molecular diagnosis, and ending the diagnostic odyssey',
    'providing a refined molecular characterisation that resolves the apparent karyotype as an unbalanced deletion-inversion-deletion event in Case 1 and identifies dosage-sensitive disease genes (the 8p23.1 microdeletion region, AUTS2, CNTNAP2) as the most likely contributors to each proband\'s phenotype'
)

# ===========================================================================
# Step 13. Insert end-of-paper sections after Discussion, before References
# ===========================================================================
# Find "Reference:" header
p_ref_header = find_para('Reference')
if p_ref_header:
    # Insert sections in REVERSE order using insert_para_before so they end up
    # in the correct order: Ethics → Acknowledgements → Author contributions →
    # Funding → Competing interests → Data availability → Code availability → References
    sections = [
        # (heading, body)
        ('Ethics declarations',
         'The study was approved by the Institutional Review Board of National '
         'Cheng Kung University Hospital, Taiwan (IRB No. A-BR-109-045). Written '
         'informed consent was obtained from all adult participants or the legal '
         'guardians of paediatric probands; assent was obtained from children '
         'when developmentally appropriate. All participants (or legal guardians) '
         'provided written informed consent for the use of their de-identified '
         'medical and genetic data, including for publication.'),

        ('Acknowledgements',
         'We thank Wilson Cheng (PacBio) for providing bioinformatics analysis '
         'support, Blossom Biotechnologies, Inc. (Taiwan) for assistance in '
         'coordinating the long-read sequencing workflow, and Pharmigene, Inc. '
         '(Taiwan) for assistance with optical genome mapping.'),

        ('Author contributions',
         'Y.-M.C. — Methodology, Data curation, Formal analysis, Investigation, '
         'Software, Visualization, Writing – original draft. Y.-W.P. — '
         'Investigation, Resources. Y.-Y.C. — Investigation, Resources, '
         'Supervision, Writing – review & editing. M.-C.T. — Supervision, '
         'Writing – review & editing. P.-M.W. — Resources, Writing – review & '
         'editing. P.-L.K. — Conceptualization, Funding acquisition, Methodology, '
         'Supervision, Writing – review & editing.'),

        ('Funding',
         'This work was supported by the Clinical Medical Research Center, '
         'National Cheng Kung University Hospital (grant number NCKUH-11009023). '
         'The funder had no role in study design, data collection and analysis, '
         'decision to publish, or preparation of the manuscript.'),

        ('Competing interests',
         'The authors declare no competing interests.'),

        ('Data availability',
         'The data that support the findings of this study are available from '
         'the corresponding authors upon request. Restrictions apply because the '
         'data contain information that could compromise the privacy of the '
         'participants; access is therefore subject to local ethics-board approval.'),

        ('Code availability',
         'Custom analysis scripts (including the retrospective Manta and Delly '
         're-analysis pipelines for Case 2 and the AUTS2 per-exon coverage '
         'computation) are available from the corresponding authors upon request.'),
    ]

    # Insert in REVERSE order so they appear in the listed order before
    # the References header.
    anchor = p_ref_header
    for heading, body in reversed(sections):
        body_para = insert_para_before(anchor, body, style='Normal')
        head_para = insert_para_before(body_para, heading, style='Heading 2')
        anchor = head_para

print('Step 11-13 (limitation / softening / end sections): done')
doc.save(OUTPUT)
print('Saved:', OUTPUT)

# ===========================================================================
# Step 14. Add new references and resolve [REF_*] placeholders
# ===========================================================================
# Existing references go up to [41]. We add three new refs:
#   [42] Korbel JO, Campbell PJ. Cell. 2013 (chromothripsis criteria)
#   [43] Chen X, Saunders CT et al. Manta. Bioinformatics 2016
#   [44] Rausch T et al. Delly. Bioinformatics 2012

# Find last existing reference (e.g. "[41]")
last_ref = None
for p in doc.paragraphs:
    if p.text.startswith('[41]'):
        last_ref = p
        break

if last_ref:
    new_refs = [
        '[42] Korbel JO, Campbell PJ. Criteria for inference of chromothripsis in cancer genomes. Cell. 2013;152:1226-36.',
        '[43] Chen X, Schulz-Trieglaff O, Shaw R, Barnes B, Schlesinger F, Källberg M, et al. Manta: rapid detection of structural variants and indels for germline and cancer sequencing applications. Bioinformatics. 2016;32:1220-2.',
        '[44] Rausch T, Zichner T, Schlattl A, Stütz AM, Benes V, Korbel JO. DELLY: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics. 2012;28:i333-9.',
    ]
    anchor = last_ref
    for txt in new_refs:
        # Use Normal style; some EndNote bibliographies use a special style,
        # but Normal is safe and editable.
        anchor = insert_para_after(anchor, txt, style='Normal')

# Replace placeholders with the assigned numbers
replace_all_in_doc('[REF_KORBEL]', '[42]')
replace_all_in_doc('[REF_MANTA]',  '[43]')
replace_all_in_doc('[REF_DELLY]',  '[44]')

# ===========================================================================
# Step 15. Add Supplementary Table 6 stub for Manta + Delly + AUTS2 depth
# ===========================================================================
# Append at end of supplementary section
last_sup = None
for p in doc.paragraphs:
    if p.text.startswith('Supplementary Figure 1'):
        last_sup = p
        break

# Find the last paragraph in the document if Supplementary Figure 1 not detected
if last_sup is None:
    last_sup = doc.paragraphs[-1]

# Insert a new Sup Table 6 header after the entire current supplementary section
# (placed at the very end so the user can position it later)
last = doc.paragraphs[-1]
sup6_block = [
    ('Supplementary Table 6. Retrospective short-read SV re-analysis of the Case 2 WES BAM (Manta v1.6.0 and Delly v1.2.6) and per-base read depth at AUTS2 exons (NM_015570.4) and at the LRS-defined inversion breakpoints.', 'Normal'),
    ('Footnote. Manta was run with --exome and without restricting --callRegions; Delly was run with default parameters. The reference used was GRCh38_full_analysis_set_plus_decoy_hla.fa. Per-base mean depth was computed with samtools depth -a. Across the 19 captured AUTS2 exons, mean depth ranged from 35.90× to 274.85× (median 106.09×). The two LRS-defined breakpoints (chr7:69,938,691, AUTS2 intron 2; chr7:95,720,897, 7q21.3) showed mean depths of 0.07× and 0.16×, respectively, and 0 / 0 records within ±50 kb in Manta diploidSV / candidateSV and Delly. Genome-wide, Manta produced 129 chromosome-7 candidate SVs and Delly produced 142 chromosome-7 SV records, confirming that both callers operated normally.', 'Normal'),
]
for txt, style in sup6_block:
    last = insert_para_after(last, txt, style=style)

print('Step 14-15 (references / supplementary table 6): done')
doc.save(OUTPUT)
print('Saved:', OUTPUT)

# ===========================================================================
# Step 16. Fix typo in Table 3 (LRS SV summary) — Case 3 duplications "27,38" -> "2,738"
# ===========================================================================
# The cell content is split across three runs ('27' / ',' / '38') in the
# original docx, so per-run substring matching fails. Detect by cell.text
# and rewrite the runs of the first paragraph.
for tbl in doc.tables:
    for row in tbl.rows:
        for cell in row.cells:
            if '27,38' in cell.text and '2,738' not in cell.text:
                p = cell.paragraphs[0]
                if p.runs:
                    p.runs[0].text = '2,738'
                    for r in p.runs[1:]:
                        r.text = ''

print('Step 16 (table 3 typo): done')
doc.save(OUTPUT)
print('Final save:', OUTPUT)

# ===========================================================================
# Verification
# ===========================================================================
out = docx.Document(OUTPUT)
print()
print('=== VERIFICATION ===')
print('Total paragraphs in revised:', len(out.paragraphs))

checks = [
    ('Abstract heading', lambda d: any(p.text.startswith('Abstract') for p in d.paragraphs)),
    ('3.2 Case 2 numbering', lambda d: any(p.text.startswith('3.2 Case 2') for p in d.paragraphs)),
    ('Bayley-III Case 3 75/65/79', lambda d: any('(Cognitive 75, Language 65, Motor 79)' in p.text for p in d.paragraphs)),
    ('Bayley-III Case 1 still 65/56/61', lambda d: any('(Cognitive 65, Language 56, Motor 61)' in p.text for p in d.paragraphs)),
    ('UHMW (UMWH fixed)', lambda d: any('UHMW gDNA' in p.text for p in d.paragraphs) and not any('UMWH' in p.text for p in d.paragraphs)),
    ('Recruitment dates', lambda d: any('between March 2023 and October 2024' in p.text for p in d.paragraphs)),
    ('Yen-Yin Chou lead corresponding', lambda d: any('Yen-Yin Chou (lead corresponding' in p.text for p in d.paragraphs)),
    ('HiFiCNV v1.0.1', lambda d: any('HiFiCNV (v1.0.1)' in p.text for p in d.paragraphs)),
    ('SNV pipeline VEP+ANNOVAR', lambda d: any('Ensembl Variant Effect Predictor' in p.text for p in d.paragraphs)),
    ('gnomAD v4.1', lambda d: any('gnomAD v4.1' in p.text for p in d.paragraphs)),
    ('AlphaMissense+SpliceAI', lambda d: any('AlphaMissense' in p.text and 'SpliceAI' in p.text for p in d.paragraphs)),
    ('Manta v1.6.0 in Discussion', lambda d: any('Manta v1.6.0' in p.text for p in d.paragraphs)),
    ('Delly v1.2.6 in Discussion', lambda d: any('Delly v1.2.6' in p.text for p in d.paragraphs)),
    ('Sanger/trio limitation', lambda d: any('breakpoint junctions and parental trio samples could not be' in p.text for p in d.paragraphs)),
    ('Chromoanagenesis softened (Korbel)', lambda d: any('Korbel and Campbell' in p.text for p in d.paragraphs)),
    ('OMIM gene list (BRAF, AGK, ...)', lambda d: any('BRAF, AGK, CLCN1' in p.text for p in d.paragraphs)),
    ('Acknowledgements section', lambda d: any(p.text.startswith('Acknowledgements') for p in d.paragraphs)),
    ('Funding section', lambda d: any(p.text.startswith('Funding') for p in d.paragraphs)),
    ('Author contributions', lambda d: any(p.text.startswith('Author contributions') for p in d.paragraphs)),
    ('Competing interests', lambda d: any(p.text.startswith('Competing interests') for p in d.paragraphs)),
    ('Data availability', lambda d: any(p.text.startswith('Data availability') for p in d.paragraphs)),
    ('Code availability', lambda d: any(p.text.startswith('Code availability') for p in d.paragraphs)),
    ('Ethics declarations', lambda d: any(p.text.startswith('Ethics declarations') for p in d.paragraphs)),
    ('Ref [42] Korbel', lambda d: any(p.text.startswith('[42] Korbel JO') for p in d.paragraphs)),
    ('Ref [43] Manta', lambda d: any(p.text.startswith('[43] Chen X') for p in d.paragraphs)),
    ('Ref [44] Delly', lambda d: any(p.text.startswith('[44] Rausch T') for p in d.paragraphs)),
    ('Sup Table 6', lambda d: any(p.text.startswith('Supplementary Table 6') for p in d.paragraphs)),
    ('Pharmigene OGM', lambda d: any('Pharmigene' in p.text for p in d.paragraphs)),
    ('Blossom acknowledgement', lambda d: any('Blossom Biotechnologies' in p.text for p in d.paragraphs)),
    ('Wilson Cheng', lambda d: any('Wilson Cheng' in p.text for p in d.paragraphs)),
    ('Whereas → whereas', lambda d: not any('Moreover, Whereas' in p.text for p in d.paragraphs)),
    ('upper track (tract → track)', lambda d: not any('upper tract' in p.text for p in d.paragraphs)),
    ('Figure 3D coordinate (chr7:139)', lambda d: any('chr7:139 Mb' in p.text for p in d.paragraphs)),
    ('Table 3 Case 3 duplications fixed (no 27,38)', lambda d: not any('27,38' in (cell.text for tbl in d.tables for row in tbl.rows for cell in row.cells))),
]
for name, check in checks:
    try:
        ok = check(out)
        status = 'OK' if ok else 'FAIL'
    except Exception as e:
        status = f'ERR ({e})'
    print(f'  [{status}] {name}')
