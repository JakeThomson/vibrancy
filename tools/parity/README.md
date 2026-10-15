# Parity tooling

Dev-only scripts for checking the package against UIKit. Not part of the
package.

Requirements: Python 3 with numpy and Pillow, Xcode with the `native/` project
(generated with `xcodegen` from its `project.yml`) installed on the parity
simulator, and the example's parity entry point installed there too
(`flutter build ios --simulator --debug -t lib/parity/main.dart` in
`example/`).

    ./capture.sh <native|flutter> <scene> <material> <style> <light|dark> <out.png>
    python3 extract_matrices.py out/dump-light.txt out/dump-dark.txt > out/matrices.json
    python3 check_matrix.py shot.png "m0,...,m19"     # swatch page against a matrix
    python3 compare_card.py native.png flutter.png side.png
    python3 ../generate_matrices.py                   # lib/src/vibrancy_matrices.dart
    ./screenshots.sh                                  # docs/demo/ and screenshots/

Scenes, picked with `VIB_SCENE` and shared by both apps:

- `dump` (native only) builds every material and style and writes the layer
  trees, with the private filters UIKit hangs on them, to
  `Documents/dump-<light|dark>.txt` in the app's container. `out/` holds the
  iOS 27.0 dumps the package's matrices come from.
- `swatches` lays rows of solid colour under vibrant squares of white, black,
  red and half-transparent white (`VIB_BLUR`, `VIB_STYLE`).
- `card` is a place card over a photo under a material, then a patch and a
  name per style (`VIB_BLUR`). With `VIB_HIDE=1` the native page hides its
  content; that capture, copied to `example/assets/parity/`, is the Flutter
  page's backdrop, so the two are compared over the same pixels.
- `perf` (Flutter only) scrolls forty cards and logs `PERF …` frame times;
  `VIB_PERF_OFF=1` disables every `Vibrancy` for the baseline.
- `place`, `player`, `settings` and `styles` (Flutter only) are the gallery's
  pages, with vibrancy off under `VIB_PERF_OFF=1`; `scroll` is the styles
  page scrolling itself, for the README's recording.

The simulator UDID lives in `parity.env`. `capture.sh` forwards the switches
with simctl's `SIMCTL_CHILD_` prefix; the Flutter Runner hands them to Dart
over a method channel. Screenshots go to `../vibrancy-colours_parity/`, not
the repository.
