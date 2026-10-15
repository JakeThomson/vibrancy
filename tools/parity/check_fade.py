"""Checks vibrant content under a translucent ancestor.

    python3 check_fade.py bare.png opaque.png faded.png opacity

At opacity o the faded page should be the opaque page blended o of the way
from the bare one. Prints the worst and 99th-percentile channel error over
the content, in 0-255.
"""
import sys

import numpy as np
from PIL import Image


def load(path):
    return np.asarray(Image.open(path).convert('RGB')).astype(float)


def main():
    bare, opaque, faded = (load(p) for p in sys.argv[1:4])
    opacity = float(sys.argv[4])
    expected = bare * (1 - opacity) + opaque * opacity
    # The content's rows, below the status bar: where opaque differs from bare.
    content = np.abs(opaque - bare).max(axis=2) > 2
    content[:300] = False
    error = np.abs(faded - expected).max(axis=2)[content]
    print(f'pixels={content.sum()} worst={error.max():.1f} p99={np.percentile(error, 99):.1f}')


if __name__ == '__main__':
    main()
