"""Compares the card page of the two apps: one line per patch, and a
side-by-side image.

    python3 compare_card.py native.png flutter.png side.png
"""
import sys

from PIL import Image

STYLES = ['label', 'secondaryLabel', 'tertiaryLabel', 'quaternaryLabel',
          'fill', 'secondaryFill', 'tertiaryFill', 'separator']


def main():
    native = Image.open(sys.argv[1]).convert('RGB')
    flutter = Image.open(sys.argv[2]).convert('RGB')
    worst = 0
    for i, style in enumerate(STYLES):
        x, y = int((24 + 75) * 3), int((364 + i * 52 + 20) * 3)
        a, b = native.getpixel((x, y)), flutter.getpixel((x, y))
        err = max(abs(p - q) for p, q in zip(a, b))
        worst = max(worst, err)
        print(f'{style:16s} native={a} flutter={b} err={err}')
    print(f'worst {worst}')
    w, h = native.size
    top = 100 * 3
    side = Image.new('RGB', (w * 2 + 30, h - top), (255, 0, 255))
    side.paste(native.crop((0, top, w, h)), (0, 0))
    side.paste(flutter.crop((0, top, w, h)), (w + 30, 0))
    side.resize((side.width // 2, side.height // 2)).save(sys.argv[3])


if __name__ == '__main__':
    main()
