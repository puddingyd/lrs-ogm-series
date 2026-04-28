#!/usr/bin/env python3
"""count_genes_8p22.py
Count protein-coding RefSeq genes wholly or partially within the 8p22
deletion interval (Case 1, NCKUH_LRS_002) for ACMG/ClinGen 2020 (Riggs)
Section 3 scoring.

Section 3 thresholds:
  3A:  0-24 protein-coding RefSeq genes  -> +0.00
  3B: 25-34 protein-coding RefSeq genes  -> +0.45
  3C:    ≥35 protein-coding RefSeq genes -> +0.90
"""
import json
import urllib.request
import sys

CHROM = 'chr8'
START = 12477756
STOP  = 16798965

URL = (f'https://api.genome.ucsc.edu/getData/track'
       f'?genome=hg38;track=ncbiRefSeqCurated'
       f';chrom={CHROM};start={START};end={STOP}')

print(f'Querying UCSC for ncbiRefSeqCurated transcripts in {CHROM}:{START:,}-{STOP:,}')
print(f'Region size: {(STOP - START) / 1e6:.2f} Mb\n')

with urllib.request.urlopen(URL) as r:
    data = json.load(r)

items = data.get('ncbiRefSeqCurated', [])
print(f'Total transcripts returned: {len(items)}\n')

# Each item is a transcript. We count unique gene symbols (name2 field).
# A "protein-coding" RefSeq transcript starts with "NM_" (vs NR_* for non-coding).
protein_coding_genes = set()
non_coding_genes    = set()
all_genes           = set()
for it in items:
    name  = it.get('name', '')
    name2 = it.get('name2', '')
    if not name2:
        continue
    all_genes.add(name2)
    if name.startswith('NM_'):
        protein_coding_genes.add(name2)
    elif name.startswith('NR_') or name.startswith('XR_'):
        non_coding_genes.add(name2)

print(f'Unique gene symbols total:           {len(all_genes)}')
print(f'  Protein-coding (NM_*):             {len(protein_coding_genes)}')
print(f'  Non-coding only (NR_/XR_):         {len(non_coding_genes - protein_coding_genes)}')
print()

# Sort and list protein-coding genes
print('=== Protein-coding genes (alphabetical) ===')
for g in sorted(protein_coding_genes):
    print(f'  {g}')

# Riggs 3 scoring
n = len(protein_coding_genes)
print()
print('=== Riggs 2020 Section 3 scoring ===')
if n <= 24:
    print(f'  3A applies: 0-24 genes (n={n}) -> +0.00')
elif n <= 34:
    print(f'  3B applies: 25-34 genes (n={n}) -> +0.45')
else:
    print(f'  3C applies: >=35 genes (n={n}) -> +0.90')
