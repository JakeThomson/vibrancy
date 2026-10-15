"""Writes lib/src/vibrancy_matrices.dart from the harness's layer dumps.

    python3 tools/generate_matrices.py

Reads `tools/parity/out/dump-light.txt` and `dump-dark.txt` (written by the
`native/` harness's `dump` scene) for the `vibrantColorMatrix` UIKit puts on
each vibrancy view's content layer.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DUMPS = os.path.join(ROOT, 'tools', 'parity', 'out')
OUT = os.path.join(ROOT, 'lib', 'src', 'vibrancy_matrices.dart')

MATERIALS = ['ultraThin', 'thin', 'regular', 'thick', 'chrome']
STYLES = [
    'secondaryLabel', 'tertiaryLabel', 'quaternaryLabel',
    'fill', 'secondaryFill', 'tertiaryFill', 'separator',
]


def parse(path):
    result = {}
    name = None
    for line in open(path):
        if line.startswith('=== '):
            name = line[4:].strip()
            continue
        if name and ' / ' in name and 'vibrantColorMatrix' in line:
            values = re.search(r'inputColorMatrix=[^\[]*\[([^\]]*)\]', line).group(1)
            material, style = name.split(' / ')
            result[(material, style)] = tuple(float(v) for v in values.split(','))
    return result


def number(x):
    s = f'{x:.5f}'.rstrip('0')
    return s + '0' if s.endswith('.') else s


def main():
    dumps = {b: parse(os.path.join(DUMPS, f'dump-{b}.txt')) for b in ('light', 'dark')}
    ids = {}
    table = {}
    for brightness, dump in dumps.items():
        for material in MATERIALS:
            assert (material, 'label') not in dump, 'label is expected to draw as it is'
            for style in STYLES:
                m = dump[(material, style)]
                # Only the colour rows vary: no channel reads alpha and the
                # alpha row is the identity.
                assert m[3] == m[8] == m[13] == 0 and m[15:] == (0, 0, 0, 1, 0), m
                ids.setdefault(m, f'_m{len(ids):02d}')
                table[(brightness, material, style)] = ids[m]

    constants = []
    for m, name in ids.items():
        rows = ''.join(
            f'  {number(m[i])}, {number(m[i + 1])}, {number(m[i + 2])}, {number(m[i + 4])},'
            + (' //\n' if i == 0 else '\n')
            for i in (0, 5, 10)
        )
        constants.append(f'const {name} = VibrancyMatrix(<double>[\n{rows}]);')

    cases = []
    for brightness in ('light', 'dark'):
        cases.append(f'    Brightness.{brightness} => switch (material) {{')
        groups = {}
        for material in MATERIALS:
            key = tuple(table[(brightness, material, s)] for s in STYLES)
            groups.setdefault(key, []).append(material)
        for key, materials in groups.items():
            pattern = ' || '.join(f'VibrancyMaterial.{m}' for m in materials)
            cases.append(f'      {pattern} => switch (style) {{')
            cases.append('        VibrancyStyle.label => null,')
            for style, name in zip(STYLES, key):
                cases.append(f'        VibrancyStyle.{style} => {name},')
            cases.append('      },')
        cases.append('    },')

    nl = '\n'
    source = f'''// The colour matrices UIKit's vibrancy applies, as measured on iOS 27.0.
//
// Read out of the `vibrantColorMatrix` filter UIKit hangs on a vibrancy
// view's content layer (`tools/parity/out/dump-*.txt`, written by the
// harness in `native/`) by `tools/generate_matrices.py`. Do not edit by hand.

import 'dart:ui' show Brightness;

import 'vibrancy_matrix.dart';
import 'vibrancy_style.dart';

{(nl + nl).join(constants)}

/// The matrix UIKit applies to the backdrop for [style] over [material] in
/// [brightness], or null for [VibrancyStyle.label], which UIKit draws as it
/// is.
VibrancyMatrix? vibrancyMatrix(
  VibrancyStyle style,
  VibrancyMaterial material,
  Brightness brightness,
) {{
  return switch (brightness) {{
{nl.join(cases)}
  }};
}}
'''
    with open(OUT, 'w') as f:
        f.write(source)


if __name__ == '__main__':
    main()
