import 'dart:ui' show ColorFilter;

/// The colour rows of a Core Animation `CAColorMatrix`, each
/// `[r, g, b, bias]`: an output channel is
/// `r * red + g * green + b * blue + bias`, in non-linear sRGB with the bias
/// in [0, 1].
///
/// UIKit's vibrancy matrices leave alpha alone and read no alpha, so only
/// these three rows vary.
final class VibrancyMatrix {
  /// Creates a matrix from its red, green and blue rows.
  const VibrancyMatrix(this.rows);

  /// The red, green and blue rows, four values each.
  final List<double> rows;

  /// The matrix as a [ColorFilter], whose bias is in [0, 255].
  ColorFilter toColorFilter() => ColorFilter.matrix(<double>[
    rows[0], rows[1], rows[2], 0, rows[3] * 255, //
    rows[4], rows[5], rows[6], 0, rows[7] * 255,
    rows[8], rows[9], rows[10], 0, rows[11] * 255,
    0, 0, 0, 1, 0,
  ]);
}
