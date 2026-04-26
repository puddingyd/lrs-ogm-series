#!/usr/bin/env python3
"""
hificnv_oscillation.py

Apply Korbel & Campbell (Cell 2013) chromothripsis criteria — specifically
the copy-number oscillation requirement — to the HiFiCNV per-bin output for
Case 3 (PacBio HiFi WGS).

Korbel & Campbell criteria (paraphrased):
  C1. Clustered breakpoints (≥10 breakpoints in <50 Mb)
  C2. Copy-number oscillation between 2 (or rarely 3) discrete copy-number
      states across the affected interval
  C3. Apparently random orientation of joined fragments
  C4. Localisation to one or a few chromosomes / regions

This script tests C2 (the most quantitative, tool-derived criterion) by:
  (a) Reading HiFiCNV per-bin copy-number output (typically a .copynum.bedgraph
      or a .vcf.gz of CNV calls).  If a per-bin bedgraph is unavailable, falls
      back to the depth file produced by HiFiCNV (`*.depth.bw` -> bedGraph via
      bigWigToBedGraph, or HiFiCNV's `*.copynum.bedgraph`).
  (b) Restricting to the affected chromosomes (chr2, chr5, chr7, chr13).
  (c) Discretising bin copy numbers to integer states (0, 1, 2, 3, ...).
  (d) Counting state transitions across each chromosome and within +/- 5 Mb of
      each LRS-defined breakpoint.
  (e) Reporting whether the locus shows oscillation between 2 (or 3) states
      consistent with the Korbel & Campbell criterion.

Usage:
  edit the CONFIG block to point to the HiFiCNV outputs, then:
      python3 hificnv_oscillation.py

Outputs (under OUTDIR):
  case3_oscillation_summary.tsv       — per-region transition counts and verdict
  case3_oscillation_<chr>.png         — copy-number track plot (if matplotlib present)
"""
import os
import sys
import gzip
from collections import defaultdict

# ============================================================================
# CONFIG — edit to point at your local HiFiCNV outputs
# ============================================================================
# HiFiCNV writes per-bin copy-number to <prefix>.copynum.bedgraph
# (4 cols: chrom, start, end, copynumber). Check your HiFi-WGS output dir.
COPYNUM_BEDGRAPH = '/Users/changym/Desktop/LR_WGS/Case3/hifi_output/case3.copynum.bedgraph'

# Output directory
OUTDIR = '/Users/changym/Desktop/LR_WGS/Case3/oscillation_analysis'

# Chromosomes affected by the rearrangement (from manuscript)
AFFECTED_CHROMS = ['chr2', 'chr5', 'chr7', 'chr13']

# LRS-defined breakpoints (chrom, position) for Case 3
BREAKPOINTS = [
    ('chr2', 190165024,  't(2;13) junction A'),
    ('chr2', 195916610,  '2q33.2 inv proximal'),
    ('chr2', 204194605,  '2q33.2 inv distal'),
    ('chr2', 208167781,  '2q33.3 1-kb del start'),
    ('chr2', 208168760,  '2q33.3 1-kb del end'),
    ('chr2', 208484607,  'local inv start'),
    ('chr2', 208561732,  'local inv end / insertion start'),
    ('chr2', 212365904,  'insertion end'),
    ('chr5', 63691635,   't(5;7) junction'),
    ('chr7', 134079073,  't(5;7) chr7 partner'),
    ('chr7', 139635053,  '7q34 deletion start'),
    ('chr7', 145048896,  '7q34-q35 deletion end / inv start'),
    ('chr7', 146600257,  '7q35 inv end (CNTNAP2)'),
    ('chr13', 62374243,  '13q21.31 fragment start'),
    ('chr13', 63090549,  '13q21.31 fragment end'),
    ('chr13', 89823743,  't(2;13) chr13 partner'),
]

# Window around each breakpoint to check for oscillation (Korbel & Campbell
# typically considers <50 Mb; we use +/- 5 Mb for a focused check around each
# breakpoint, then also report whole-chromosome).
LOCAL_WINDOW = 5_000_000

# Discretisation: round bin copy number to nearest integer
def discretise(cn):
    return int(round(cn))

# ============================================================================
# Read per-bin bedGraph
# ============================================================================
def read_bedgraph(path):
    """Yield (chrom, start, end, copynumber) tuples."""
    opener = gzip.open if path.endswith('.gz') else open
    with opener(path, 'rt') as fh:
        for line in fh:
            if line.startswith('#') or line.startswith('track'):
                continue
            parts = line.rstrip().split('\t')
            if len(parts) < 4:
                continue
            chrom = parts[0]
            try:
                start = int(parts[1]); end = int(parts[2])
                cn    = float(parts[3])
            except ValueError:
                continue
            yield chrom, start, end, cn

def main():
    if not os.path.isfile(COPYNUM_BEDGRAPH):
        print(f'ERROR: copynum bedgraph not found: {COPYNUM_BEDGRAPH}', file=sys.stderr)
        print()
        print('Locate it under your HiFiCNV output. Typical paths:')
        print('  <run_dir>/hificnv/<sample>.copynum.bedgraph')
        print('  <run_dir>/hificnv/<sample>.copynum.bw   (convert with bigWigToBedGraph)')
        sys.exit(1)

    os.makedirs(OUTDIR, exist_ok=True)

    # Bin records by chromosome
    bins_by_chrom = defaultdict(list)
    for ch, s, e, cn in read_bedgraph(COPYNUM_BEDGRAPH):
        if ch in AFFECTED_CHROMS:
            bins_by_chrom[ch].append((s, e, cn))
    for ch, bins in bins_by_chrom.items():
        bins.sort()
        print(f'  {ch}: {len(bins)} bins')

    out_lines = ['region\tn_bins\tdistinct_states\tn_transitions\toscillation_pattern\toscillation_present\tverdict']

    def analyse(label, bins):
        if not bins:
            return f'{label}\t0\t0\t0\t-\tFalse\tno data'
        states = [discretise(cn) for _, _, cn in bins]
        # Smooth singleton outliers (1-bin-wide)
        smoothed = list(states)
        for i in range(1, len(smoothed)-1):
            if smoothed[i-1] == smoothed[i+1] and smoothed[i] != smoothed[i-1]:
                smoothed[i] = smoothed[i-1]
        distinct = sorted(set(smoothed))
        # Count transitions (changes in state)
        transitions = sum(1 for i in range(1, len(smoothed)) if smoothed[i] != smoothed[i-1])
        # Oscillation = repeated alternation between 2 (or 3) states
        # Build run-length encoding then detect alternation
        rle = []
        for s in smoothed:
            if rle and rle[-1][0] == s:
                rle[-1] = (s, rle[-1][1] + 1)
            else:
                rle.append((s, 1))
        rle_states = [s for s, _ in rle]
        # Korbel & Campbell: oscillation if >= 4 alternating segments between
        # 2-3 distinct states, with each segment >= 2 bins
        long_segments = [s for s, n in rle if n >= 2]
        oscillation = (len(long_segments) >= 4 and
                       2 <= len(set(long_segments)) <= 3)
        pattern = ' -> '.join(str(s) for s in rle_states[:20])
        if len(rle_states) > 20:
            pattern += f' ... ({len(rle_states)} segments total)'
        verdict = ('OSCILLATION pattern (Korbel-Campbell C2 satisfied)'
                   if oscillation else
                   'No oscillation (no chromothripsis-pattern by C2)')
        return (f'{label}\t{len(bins)}\t{len(distinct)}\t{transitions}\t'
                f'{pattern}\t{oscillation}\t{verdict}')

    # Per affected chromosome
    for ch in AFFECTED_CHROMS:
        out_lines.append(analyse(f'{ch} (whole)', bins_by_chrom[ch]))

    # Per breakpoint local window
    for ch, pos, label in BREAKPOINTS:
        local = [(s, e, cn) for (s, e, cn) in bins_by_chrom[ch]
                 if s >= pos - LOCAL_WINDOW and e <= pos + LOCAL_WINDOW]
        out_lines.append(analyse(f'{ch}:{pos:,} ±5Mb ({label})', local))

    out_path = os.path.join(OUTDIR, 'case3_oscillation_summary.tsv')
    with open(out_path, 'w') as f:
        f.write('\n'.join(out_lines))
    print()
    print('==> Summary written:', out_path)
    print()
    print('\n'.join(out_lines))

    # Optional: matplotlib plots
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print('\n(matplotlib not installed; skipping plots. `pip install matplotlib` to enable.)')
        return

    for ch, bins in bins_by_chrom.items():
        if not bins:
            continue
        xs = [(s + e) / 2 / 1e6 for s, e, _ in bins]
        ys = [cn for _, _, cn in bins]
        fig, ax = plt.subplots(figsize=(14, 3))
        ax.plot(xs, ys, lw=0.4, color='steelblue')
        ax.set_ylim(-0.5, 5.5)
        ax.set_xlabel(f'{ch} position (Mb)')
        ax.set_ylabel('Copy number')
        ax.set_title(f'HiFiCNV per-bin copy number — {ch} (Case 3)')
        # Mark breakpoints
        for c2, pos, label in BREAKPOINTS:
            if c2 == ch:
                ax.axvline(pos / 1e6, color='red', lw=0.8, alpha=0.6)
        ax.axhline(2, color='gray', ls='--', lw=0.5)
        out_png = os.path.join(OUTDIR, f'case3_oscillation_{ch}.png')
        fig.savefig(out_png, dpi=150, bbox_inches='tight')
        plt.close(fig)
        print(f'  Wrote {out_png}')

if __name__ == '__main__':
    main()
