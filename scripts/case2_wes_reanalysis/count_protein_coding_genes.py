#!/usr/bin/env python3
"""count_protein_coding_genes.py
Count protein-coding RefSeq genes wholly or partially within a given
GRCh38 region for ACMG/ClinGen 2020 (Riggs) Section 3 scoring.

Riggs 2020 Section 3 thresholds:
  3A:  0-24 genes -> +0.00
  3B: 25-34 genes -> +0.45
  3C:  >=35 genes -> +0.90

Usage:
  python3 count_protein_coding_genes.py CHROM START STOP [LABEL]

Examples:
  python3 count_protein_coding_genes.py chr8 12477756 16798965 "Case 1 8p22 del"
  python3 count_protein_coding_genes.py chr7 139635053 145048896 "Case 3 7q34-q35 del"
"""
import json
import urllib.request
import sys

def count(chrom, start, stop, label=''):
    URL = (f'https://api.genome.ucsc.edu/getData/track'
           f'?genome=hg38;track=ncbiRefSeqCurated'
           f';chrom={chrom};start={start};end={stop}')
    print(f'\n=== {label or chrom + ":" + str(start) + "-" + str(stop)} ===')
    print(f'{chrom}:{start:,}-{stop:,}  ({(stop-start)/1e6:.2f} Mb)')

    with urllib.request.urlopen(URL) as r:
        data = json.load(r)
    items = data.get('ncbiRefSeqCurated', [])

    protein_coding = set()
    non_coding     = set()
    for it in items:
        nm  = it.get('name', '')
        sym = it.get('name2', '')
        if not sym:
            continue
        if nm.startswith('NM_'):
            protein_coding.add(sym)
        elif nm.startswith('NR_') or nm.startswith('XR_'):
            non_coding.add(sym)

    n = len(protein_coding)
    print(f'Total transcripts:           {len(items)}')
    print(f'Protein-coding genes (NM_):  {n}')
    print(f'Non-coding-only (NR_/XR_):   {len(non_coding - protein_coding)}')
    print(f'\nProtein-coding genes (alphabetical):')
    for g in sorted(protein_coding):
        print(f'  {g}')

    if n <= 24:
        section, score = '3A', '+0.00'
    elif n <= 34:
        section, score = '3B', '+0.45'
    else:
        section, score = '3C', '+0.90'
    print(f'\nRiggs 2020 Section 3: {section} (n={n})  ->  Score {score}')
    return n, section, score

if __name__ == '__main__':
    if len(sys.argv) < 4:
        # Default: run for both Case 1 8p22 and Case 3 7q34-q35
        count('chr8', 12477756, 16798965, 'Case 1 — 8p22 deletion')
        count('chr7', 139635053, 145048896, 'Case 3 — 7q34-q35 deletion')
    else:
        chrom = sys.argv[1]
        start = int(sys.argv[2])
        stop  = int(sys.argv[3])
        label = sys.argv[4] if len(sys.argv) >= 5 else ''
        count(chrom, start, stop, label)
