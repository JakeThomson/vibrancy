"""Composes the README's images and pub.dev's screenshots from the captures
`screenshots.sh` takes.

    python3 readme_images.py <captures dir> <repository root>
"""
import os
import shutil
import sys

from PIL import Image, ImageDraw, ImageFont


def font(size):
    f = ImageFont.truetype('/System/Library/Fonts/SFNS.ttf', size)
    try:
        f.set_variation_by_name('Semibold')
    except (OSError, ValueError):
        pass
    return f


def rounded(im, radius):
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, im.width - 1, im.height - 1), radius, fill=255)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def phone(path, width, crop=None):
    im = Image.open(path).convert('RGB')
    if crop:
        im = im.crop(crop)
    im = im.resize((width, int(im.height * width / im.width)), Image.LANCZOS)
    return rounded(im, int(width * (0.05 if crop else 0.09)))


def compose(items, out, pad=40, caption=30):
    has_captions = any(label for _, label in items)
    width = sum(im.width for im, _ in items) + pad * (len(items) + 1)
    height = max(im.height for im, _ in items) + pad * 2 + (caption + 24 if has_captions else 0)
    canvas = Image.new('RGBA', (width, height), (255, 255, 255, 0))
    draw = ImageDraw.Draw(canvas)
    x = pad
    for im, label in items:
        canvas.paste(im, (x, pad), im)
        if label:
            f = font(caption)
            draw.text((x + (im.width - draw.textlength(label, font=f)) / 2, pad + im.height + 14),
                      label, font=f, fill=(110, 110, 115, 255))
        x += im.width + pad
    canvas.save(out)


def main():
    shots, root = sys.argv[1], sys.argv[2]
    demo = os.path.join(root, 'docs', 'demo')
    screenshots = os.path.join(root, 'screenshots')
    os.makedirs(demo, exist_ok=True)
    os.makedirs(screenshots, exist_ok=True)
    shot = lambda name: os.path.join(shots, name)  # noqa: E731

    content = (0, 300, 1206, 1650)
    compose([(phone(shot('place-off.png'), 520, content), 'Flutter colours'),
             (phone(shot('place-on.png'), 520, content), 'Vibrancy')],
            os.path.join(demo, 'before-after.png'))
    compose([(phone(shot(f'{page}-on.png'), 300), None) for page in ('place', 'player', 'settings')],
            os.path.join(demo, 'gallery.png'), pad=30)
    card = (0, 300, 1206, 2000)
    compose([(phone(shot('card-native.png'), 420, card), 'UIKit'),
             (phone(shot('card-flutter.png'), 420, card), 'Flutter')],
            os.path.join(demo, 'native-vs-flutter.png'))
    shutil.copy(shot('scroll.gif'), os.path.join(demo, 'scroll.gif'))
    for page in ('place', 'player', 'settings', 'styles'):
        im = Image.open(shot(f'{page}-on.png')).convert('RGB')
        im.resize((im.width // 2, im.height // 2), Image.LANCZOS).save(
            os.path.join(screenshots, f'{page}.webp'), quality=82)


if __name__ == '__main__':
    main()
