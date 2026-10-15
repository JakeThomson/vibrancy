"""Pulls the vibrancy colour matrices out of the harness's layer dumps.

    python3 extract_matrices.py out/dump-light.txt out/dump-dark.txt > out/matrices.json

Keys are `brightness -> material -> style`; a style whose content layer
carries no `vibrantColorMatrix` maps to null.
"""
import json
import re
import sys


def parse(path):
    result = {}
    name = None
    for line in open(path):
        if line.startswith('=== '):
            name = line[4:].strip()
            if ' / ' in name:
                material, style = name.split(' / ')
                result.setdefault(material, {})[style] = None
            continue
        if name and ' / ' in name and 'vibrantColorMatrix' in line:
            values = re.search(r'inputColorMatrix=[^\[]*\[([^\]]*)\]', line).group(1)
            material, style = name.split(' / ')
            result[material][style] = [float(v) for v in values.split(',')]
    return result


def main():
    out = {}
    for path in sys.argv[1:]:
        out['dark' if 'dark' in path else 'light'] = parse(path)
    json.dump(out, sys.stdout, indent=1)


if __name__ == '__main__':
    main()
