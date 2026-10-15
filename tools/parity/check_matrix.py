"""Checks a swatch screenshot against `vibrantColorMatrix(backdrop)`.

    python3 check_matrix.py shot.png "m0,m1,...,m19"

Samples each row's material-only cell and its vibrant white square, and
prints the square beside the matrix applied to the material, in 0-255 sRGB.
"""
import sys

import numpy as np
from PIL import Image

SCALE = 3
ORIGIN = (26, 90)
CELL = (70, 56)
ROWS = 12


def sample(img, x, y):
    px = img[int(y * SCALE) - 6:int(y * SCALE) + 6, int(x * SCALE) - 6:int(x * SCALE) + 6, :3]
    return px.reshape(-1, 3).mean(axis=0)


def main():
    img = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    m = np.array([float(v) for v in sys.argv[2].split(',')]).reshape(4, 5)
    worst = 0
    for row in range(ROWS):
        y = ORIGIN[1] + row * CELL[1] + 28
        material = sample(img, ORIGIN[0] + 35, y)
        square = sample(img, ORIGIN[0] + CELL[0] + 35, y)
        v = material / 255
        predicted = np.clip(m[:3, :3] @ v + m[:3, 4], 0, 1) * 255
        err = np.abs(predicted - square).max()
        worst = max(worst, err)
        print(f'{row:2d} material={material.round()} square={square.round()} predicted={predicted.round()} err={err:.1f}')
    print(f'worst {worst:.1f}')


if __name__ == '__main__':
    main()
