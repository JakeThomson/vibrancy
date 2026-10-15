// The colour matrices UIKit's vibrancy applies, as measured on iOS 27.0.
//
// Read out of the `vibrantColorMatrix` filter UIKit hangs on a vibrancy
// view's content layer (`tools/parity/out/dump-*.txt`, written by the
// harness in `native/`) by `tools/generate_matrices.py`. Do not edit by hand.

import 'dart:ui' show Brightness;

import 'vibrancy_matrix.dart';
import 'vibrancy_style.dart';

const _m00 = VibrancyMatrix(<double>[
  0.9363, -0.32186, -0.06193, 0.04875, //
  -0.16355, 0.77865, -0.0626, 0.04875,
  -0.16422, -0.32087, 1.03759, 0.04875,
]);

const _m01 = VibrancyMatrix(<double>[
  0.92256, -0.15247, -0.02909, 0.0195, //
  -0.07731, 0.848, -0.02969, 0.0195,
  -0.07791, -0.15157, 0.97047, 0.0195,
]);

const _m02 = VibrancyMatrix(<double>[
  1.23555, -0.32346, -0.06209, 0.0, //
  -0.16426, 1.07719, -0.06293, 0.0,
  -0.16511, -0.32219, 1.3373, 0.0,
]);

const _m03 = VibrancyMatrix(<double>[
  1.51412, -0.95475, -0.18437, 0.0625, //
  -0.4856, 1.04619, -0.18558, 0.0625,
  -0.48681, -0.95294, 1.81475, 0.0625,
]);

const _m04 = VibrancyMatrix(<double>[
  1.17764, -0.1426, -0.02704, -0.084, //
  -0.07219, 1.10798, -0.0278, -0.084,
  -0.07294, -0.14147, 1.22241, -0.084,
]);

const _m05 = VibrancyMatrix(<double>[
  1.40758, -0.57483, -0.11075, 0.019, //
  -0.29219, 1.12596, -0.11177, 0.019,
  -0.29322, -0.57329, 1.58851, 0.019,
]);

const _m06 = VibrancyMatrix(<double>[
  1.55195, -0.8805, -0.16995, 0.04425, //
  -0.44778, 1.12044, -0.17116, 0.04425,
  -0.44899, -0.87868, 1.82917, 0.04425,
]);

const _m07 = VibrancyMatrix(<double>[
  1.201, -0.58766, -0.11334, 0.1, //
  -0.2988, 0.91304, -0.11425, 0.1,
  -0.2997, -0.5863, 1.386, 0.1,
]);

const _m08 = VibrancyMatrix(<double>[
  0.82807, -0.33796, -0.06511, 0.5375, //
  -0.17179, 0.6625, -0.06572, 0.5375,
  -0.17239, -0.33706, 0.93445, 0.5375,
]);

const _m09 = VibrancyMatrix(<double>[
  1.04004, -0.31457, -0.06046, 0.3175, //
  -0.1598, 0.88599, -0.06119, 0.3175,
  -0.16053, -0.31348, 1.13901, 0.3175,
]);

const _m10 = VibrancyMatrix(<double>[
  1.22658, -0.34107, -0.06551, 0.18, //
  -0.17323, 1.05958, -0.06635, 0.18,
  -0.17408, -0.3398, 1.33388, 0.18,
]);

const _m11 = VibrancyMatrix(<double>[
  1.37625, -0.73452, -0.14173, 0.5, //
  -0.37351, 1.0163, -0.14279, 0.5,
  -0.37457, -0.73293, 1.6075, 0.5,
]);

const _m12 = VibrancyMatrix(<double>[
  1.06053, -0.07797, -0.01457, 0.12, //
  -0.03932, 1.02255, -0.01523, 0.12,
  -0.03998, -0.07697, 1.08495, 0.12,
]);

const _m13 = VibrancyMatrix(<double>[
  1.39622, -0.59714, -0.11508, 0.298, //
  -0.30355, 1.10366, -0.11611, 0.298,
  -0.30458, -0.5956, 1.58418, 0.298,
]);

const _m14 = VibrancyMatrix(<double>[
  1.17349, -0.64166, -0.12383, 0.556, //
  -0.3263, 0.85904, -0.12474, 0.556,
  -0.32721, -0.6403, 1.37551, 0.556,
]);

const _m15 = VibrancyMatrix(<double>[
  0.6603, -0.17643, -0.03387, 0.46, //
  -0.0896, 0.57392, -0.03432, 0.46,
  -0.09005, -0.17575, 0.7158, 0.46,
]);

/// The matrix UIKit applies to the backdrop for [style] over [material] in
/// [brightness], or null for [VibrancyStyle.label], which UIKit draws as it
/// is.
VibrancyMatrix? vibrancyMatrix(
  VibrancyStyle style,
  VibrancyMaterial material,
  Brightness brightness,
) {
  return switch (brightness) {
    Brightness.light => switch (material) {
      VibrancyMaterial.ultraThin || VibrancyMaterial.thin => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m00,
        VibrancyStyle.tertiaryLabel => _m01,
        VibrancyStyle.quaternaryLabel => _m02,
        VibrancyStyle.fill => _m03,
        VibrancyStyle.secondaryFill => _m02,
        VibrancyStyle.tertiaryFill => _m04,
        VibrancyStyle.separator => _m05,
      },
      VibrancyMaterial.regular || VibrancyMaterial.thick => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m06,
        VibrancyStyle.tertiaryLabel => _m05,
        VibrancyStyle.quaternaryLabel => _m02,
        VibrancyStyle.fill => _m03,
        VibrancyStyle.secondaryFill => _m02,
        VibrancyStyle.tertiaryFill => _m04,
        VibrancyStyle.separator => _m05,
      },
      VibrancyMaterial.chrome => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m06,
        VibrancyStyle.tertiaryLabel => _m05,
        VibrancyStyle.quaternaryLabel => _m02,
        VibrancyStyle.fill => _m07,
        VibrancyStyle.secondaryFill => _m02,
        VibrancyStyle.tertiaryFill => _m04,
        VibrancyStyle.separator => _m05,
      },
    },
    Brightness.dark => switch (material) {
      VibrancyMaterial.ultraThin || VibrancyMaterial.thin => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m08,
        VibrancyStyle.tertiaryLabel => _m09,
        VibrancyStyle.quaternaryLabel => _m10,
        VibrancyStyle.fill => _m11,
        VibrancyStyle.secondaryFill => _m10,
        VibrancyStyle.tertiaryFill => _m12,
        VibrancyStyle.separator => _m13,
      },
      VibrancyMaterial.regular || VibrancyMaterial.thick => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m14,
        VibrancyStyle.tertiaryLabel => _m13,
        VibrancyStyle.quaternaryLabel => _m10,
        VibrancyStyle.fill => _m11,
        VibrancyStyle.secondaryFill => _m10,
        VibrancyStyle.tertiaryFill => _m12,
        VibrancyStyle.separator => _m13,
      },
      VibrancyMaterial.chrome => switch (style) {
        VibrancyStyle.label => null,
        VibrancyStyle.secondaryLabel => _m14,
        VibrancyStyle.tertiaryLabel => _m13,
        VibrancyStyle.quaternaryLabel => _m10,
        VibrancyStyle.fill => _m15,
        VibrancyStyle.secondaryFill => _m10,
        VibrancyStyle.tertiaryFill => _m12,
        VibrancyStyle.separator => _m13,
      },
    },
  };
}
