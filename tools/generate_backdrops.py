"""Writes the example's backdrops: soft colour fields that read as blurred
photos, generated so the repository carries no third-party images.

    python3 tools/generate_backdrops.py
"""
import os

import numpy as np
from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'example', 'assets')
W, H = 1206, 2622

# (centre x, centre y, radius as a fraction of the width, colour)
SCENES = {
    'sky': ((180, 186, 196), [
        (0.15, 0.05, 0.35, (214, 190, 150)), (0.75, 0.12, 0.35, (120, 160, 215)),
        (0.3, 0.35, 0.4, (110, 150, 210)), (0.85, 0.45, 0.3, (150, 150, 140)),
        (0.2, 0.65, 0.35, (210, 200, 185)), (0.7, 0.75, 0.4, (90, 130, 190)),
        (0.4, 0.95, 0.35, (200, 170, 140)), (0.95, 0.95, 0.25, (70, 90, 120)),
    ]),
    'sunset': ((236, 150, 120), [
        (0.2, 0.05, 0.5, (250, 200, 120)), (0.85, 0.15, 0.45, (240, 110, 120)),
        (0.3, 0.4, 0.45, (230, 120, 90)), (0.8, 0.5, 0.4, (170, 90, 150)),
        (0.15, 0.75, 0.4, (120, 70, 140)), (0.75, 0.9, 0.45, (60, 50, 110)),
    ]),
    'forest': ((90, 130, 90), [
        (0.8, 0.05, 0.45, (220, 225, 160)), (0.15, 0.2, 0.4, (60, 110, 70)),
        (0.6, 0.35, 0.4, (110, 160, 90)), (0.2, 0.6, 0.45, (40, 80, 60)),
        (0.85, 0.7, 0.4, (150, 170, 80)), (0.4, 0.95, 0.4, (50, 70, 45)),
    ]),
    'night': ((30, 34, 70), [
        (0.2, 0.1, 0.45, (60, 50, 120)), (0.85, 0.25, 0.35, (30, 90, 140)),
        (0.5, 0.5, 0.3, (200, 120, 60)), (0.1, 0.7, 0.35, (140, 50, 110)),
        (0.8, 0.8, 0.4, (20, 110, 120)), (0.4, 0.98, 0.35, (230, 170, 90)),
    ]),
    'spectrum': ((150, 150, 150), [
        (0.2, 0.02, 0.4, (235, 90, 80)), (0.85, 0.15, 0.4, (245, 170, 60)),
        (0.2, 0.3, 0.4, (240, 220, 90)), (0.8, 0.42, 0.4, (90, 190, 110)),
        (0.2, 0.55, 0.4, (60, 170, 200)), (0.8, 0.68, 0.4, (70, 100, 220)),
        (0.25, 0.82, 0.4, (150, 90, 210)), (0.8, 0.97, 0.4, (220, 90, 160)),
    ]),
}


def main():
    yy, xx = np.mgrid[0:H, 0:W]
    for name, (base, blobs) in SCENES.items():
        image = np.zeros((H, W, 3)) + np.array(base, dtype=float)
        for cx, cy, r, colour in blobs:
            d = ((xx - cx * W) ** 2 + (yy - cy * H) ** 2) / (r * 1.7 * W) ** 2
            weight = np.exp(-d * 2.5)[..., None]
            image = image * (1 - weight) + np.array(colour, dtype=float) * weight
        out = Image.fromarray(image.clip(0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(90))
        out.save(os.path.join(OUT, f'{name}.jpg'), quality=90)


if __name__ == '__main__':
    main()
