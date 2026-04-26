#!/usr/bin/env python3
"""diff_manuscript.py — categorised diff of the manuscript revision.

Skips Abstract, summarises reference-format-only changes, highlights
substantive content edits.
"""
import re
import docx
import difflib

ORIG = 'LRS_OGM series 2026026.docx'
REV  = 'LRS_OGM_series_2026026_revised.docx'

def texts(path):
    return [p.text for p in docx.Document(path).paragraphs if p.text.strip()]

orig = texts(ORIG)
rev  = texts(REV)

ABSTRACT_PREFIX = 'Apparently balanced chromosomal rearrangements identified by karyotyping'

# Citation patterns: bracketed in original, plain numeric in revised
RE_BR = re.compile(r'\[\s*\d+(?:\s*[-,]\s*\d+)*\s*\]')
RE_NU = re.compile(r'(?<=\s)\d+(?:[-,]\d+)*(?=[\s.,;:)])')

def strip_citations(s):
    """Remove citation tokens (both formats) so only substantive prose remains
    for comparison."""
    s = RE_BR.sub('', s)
    s = re.sub(r'(?<=\s)\d+(?:[-,]\d+)*(?=[\s.,;:)])', '', s)
    return re.sub(r'\s+', ' ', s).strip()

def is_reference_paragraph(s):
    """Detect reference-list entries (both old [N] and new N. styles)."""
    return bool(re.match(r'^(\[\d+\]|\d+\.)\s+[A-Z]', s)) and \
           ('et al' in s or '. ' in s) and \
           any(j in s for j in ['Genet', 'Cell', 'Nat ', 'Hum ', 'Bioinformatics',
                                'Genome', 'Mol ', 'Sci ', 'Am J', 'Eur J', 'J '])

def short(s, n=400):
    s = s.replace('\n', ' ').strip()
    return s if len(s) <= n else s[:n] + '…'

# ============================================================================
sm = difflib.SequenceMatcher(a=orig, b=rev, autojunk=False)

new_paragraphs = []
deleted_paragraphs = []
substantive_modifications = []
citation_only_changes = 0
reference_reformat_count = 0

for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag == 'equal':
        continue
    if tag == 'insert':
        for jj in range(j1, j2):
            t = rev[jj]
            if t.startswith(ABSTRACT_PREFIX):
                continue
            new_paragraphs.append((jj, t))
    elif tag == 'delete':
        for ii in range(i1, i2):
            deleted_paragraphs.append((ii, orig[ii]))
    elif tag == 'replace':
        # Pair indices and inspect each
        a_block = orig[i1:i2]; b_block = rev[j1:j2]
        # Use sub-matcher to align within the replace block
        smb = difflib.SequenceMatcher(a=a_block, b=b_block, autojunk=False)
        for sub_tag, x1, x2, y1, y2 in smb.get_opcodes():
            if sub_tag == 'equal':
                continue
            if sub_tag == 'insert':
                for yy in range(y1, y2):
                    t = b_block[yy]
                    if t.startswith(ABSTRACT_PREFIX):
                        continue
                    new_paragraphs.append((j1 + yy, t))
            elif sub_tag == 'delete':
                for xx in range(x1, x2):
                    deleted_paragraphs.append((i1 + xx, a_block[xx]))
            elif sub_tag == 'replace':
                for k in range(max(x2 - x1, y2 - y1)):
                    xx = x1 + k; yy = y1 + k
                    if xx < x2 and yy < y2:
                        a = a_block[xx]; b = b_block[yy]
                        if b.startswith(ABSTRACT_PREFIX) or a.startswith(ABSTRACT_PREFIX):
                            continue
                        if is_reference_paragraph(a) and is_reference_paragraph(b):
                            reference_reformat_count += 1
                            continue
                        if strip_citations(a) == strip_citations(b):
                            citation_only_changes += 1
                            continue
                        substantive_modifications.append((i1+xx, j1+yy, a, b))
                    elif xx < x2:
                        deleted_paragraphs.append((i1+xx, a_block[xx]))
                    elif yy < y2:
                        t = b_block[yy]
                        if t.startswith(ABSTRACT_PREFIX):
                            continue
                        new_paragraphs.append((j1+yy, t))

# ============================================================================
def word_diff(a, b):
    aw, bw = a.split(), b.split()
    sm2 = difflib.SequenceMatcher(a=aw, b=bw, autojunk=False)
    out = []
    for tag, i1, i2, j1, j2 in sm2.get_opcodes():
        if tag == 'equal':
            seg = ' '.join(aw[i1:i2])
            if len(seg) > 80:
                seg = seg[:40] + ' … ' + seg[-40:]
            out.append(seg)
        elif tag == 'delete':
            out.append('〔- ' + ' '.join(aw[i1:i2]) + ' -〕')
        elif tag == 'insert':
            out.append('〔+ ' + ' '.join(bw[j1:j2]) + ' +〕')
        elif tag == 'replace':
            out.append('〔- ' + ' '.join(aw[i1:i2]) + ' -〕')
            out.append('〔+ ' + ' '.join(bw[j1:j2]) + ' +〕')
    return ' '.join(out)

# ============================================================================
print('# Manuscript revision diff (Abstract excluded)')
print()
print(f'Original : `{ORIG}` — {len(orig)} non-empty paragraphs')
print(f'Revised  : `{REV}` — {len(rev)} non-empty paragraphs')
print()
print('## Summary by category')
print()
print(f'| Category | Count |')
print(f'|---|---:|')
print(f'| 🆕 New paragraphs (Abstract excluded) | **{len(new_paragraphs)}** |')
print(f'| ✏️ Substantive content modifications | **{len(substantive_modifications)}** |')
print(f'| 🔢 Reference-list entries reformatted (Nature style) | **{reference_reformat_count}** |')
print(f'| ⬆️ Body paragraphs only had citations changed to superscript | **{citation_only_changes}** |')
print(f'| ➖ Deleted paragraphs | **{len(deleted_paragraphs)}** |')
print()
print('Reference-list reformatting and citation→superscript changes are listed')
print('only as counts (they affect every reference and most body paragraphs but')
print('carry no scientific content change).')
print()

# ----------------------------------------------------------------------------
print('---')
print()
print('## 🆕 New paragraphs')
print()
for idx, t in new_paragraphs:
    print(f'### rev #{idx}')
    print()
    print(f'> {short(t, 1200)}')
    print()

print('---')
print()
print('## ✏️ Substantive content modifications')
print()
for orig_i, rev_i, a, b in substantive_modifications:
    print(f'### orig #{orig_i} → rev #{rev_i}')
    print()
    print('OLD:')
    print(f'> {short(a, 800)}')
    print()
    print('NEW:')
    print(f'> {short(b, 800)}')
    print()
    print('Inline diff:')
    print()
    print('```')
    print(word_diff(a, b)[:2000])
    print('```')
    print()

if deleted_paragraphs:
    print('---')
    print()
    print('## ➖ Deleted paragraphs')
    print()
    for idx, t in deleted_paragraphs:
        print(f'### orig #{idx}')
        print()
        print(f'> {short(t, 800)}')
        print()
