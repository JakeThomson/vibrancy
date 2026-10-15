# vibrancy: design notes

Status: 0.1.0, 2026-10-15. Measured on the iOS 27.0 simulator (iPhone 17 Pro)
with Flutter 3.47.1 on Impeller (Metal).

## 1. What UIKit does

Dumping the layer tree of a `UIVisualEffectView` with a `UIVibrancyEffect` in
its content view (`native/`, scene `dump`) shows the whole effect is one
private Core Animation filter on the vibrancy view's content layer:

    vibrantColorMatrix(inputBackdropAware=1, inputColorMatrix=CAColorMatrix[20])

The swatch page (`tools/parity/check_matrix.py`) pins its semantics down. Over
twelve solid backgrounds, a vibrant square's colour is the dumped matrix
applied to the material beneath it, in non-linear sRGB and clamped, to within
0.3/255; white, black and red squares come out identical, and a half-
transparent square is the halfway blend. So for backdrop `b` and content
alpha `a`:

    out = b * (1 - a) + clamp(M * b) * a

The content's colour plays no part. `.label` has no filter at all: UIKit draws
it as it is.

The matrices depend on the style, the material and the interface style, and
nothing else. Thin and ultra-thin share theirs, as do regular and thick;
chrome differs from regular only in `fill`. Sixteen distinct matrices cover
seven styles × five materials × light and dark
(`lib/src/vibrancy_matrices.dart`, generated from the dumps). The legacy blur
styles use the older `vibrantLight`/`vibrantDark` compositing filters instead
and are left out.

## 2. Can stock Flutter do it?

No. Nothing in the framework recolours content from what's behind it, and no
blend mode computes a 3×4 matrix of the destination: the separable modes work
channel by channel, and the non-separable ones (hue, saturation, colour,
luminosity) copy a property of the source rather than scaling the
destination's. (The secondary-label matrix, for instance, is half of a 4×
Rec. 601 saturation, plus a small offset.)

It can be built from stock primitives: `BackdropFilter` with a
`ColorFilter.matrix` gives `M * b`, and the child's alpha has to mask it. How
that mask can be applied depends on the backend.

- **Skia** starts a layer holding the filtered backdrop and composites it back
  with source-over, so the child can be drawn into it with `dstIn`.
- **Impeller** (`Canvas::SaveLayer` in `impeller/display_list/canvas.cc`)
  also starts a subpass with the filtered backdrop, but the `dstIn` approach
  turns everything outside the glyphs black. A backdrop filter's shader sees
  the whole screen in device pixels, so a mask texture passed in as a uniform
  goes stale whenever an ancestor layer moves without repainting, as a
  scrolled list item does.

## 3. The Impeller path

The filter is a plain `ColorFilter.matrix`, with the mask carried in the
scene's alpha channel.

1. The child is cut out of the scene with `dstOut`, leaving `b * (1 - a)`
   with alpha `1 - a`.
2. The filtered backdrop is drawn over the box with `dstOver`, which adds
   `M(b) * a` and makes the pixel opaque again. That is UIKit's formula
   exactly, with no precision lost.

Step 2 needs `M(b)` of the backdrop from before step 1, and Impeller's
`BackdropKey` sharing provides it. When a key is used more than once in a
frame, the first use copies the scene and filters it once, and every use,
first included, only draws from that copy with its own blend mode, without
breaking the render pass again. `VibrancyScope` makes the first use itself,
over its bounds, before its content paints. It uses `dstOver`, which leaves
the opaque scene unchanged (the display list drops a layer drawn with `dst`),
so the copy is of the backdrop alone. This is also UIKit's semantics: vibrancy
reads the material's backdrop, not the content inside the effect view. A
`Vibrancy` with no scope makes its own first use, under its own key.

Keys are per matrix, because the engine filters a shared copy once with the
first use's filter.

## 4. Cost

Scrolling forty cards with twenty vibrant pieces on screen, simulator, raster
p50 (`perf` scene):

| | ms |
|---|---|
| No vibrancy | 1.0 |
| One backdrop filter per piece (first design) | 7.2 |
| Shared reads, mask in a layer (shipped) | 3.4 |
| Shared reads, mask without a layer (not shippable) | 1.3 |

Since the shared reads cost about 0.3 ms, the remainder is the offscreen layer
each mask is drawn in, because the child's own draws have to be turned into
`dstOut`. Drawing the child with `dstOut` directly would remove it, but
Flutter offers no way to force a blend mode onto a child's draws.
Paragraph colours are baked in when the text is laid out, and `Icon` ignores
`DefaultTextStyle`. A text-only fast path, with the blend set through the
text style, is the next optimisation if device profiling calls for it.
