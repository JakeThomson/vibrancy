import 'dart:ui' show Brightness, Color, ColorFilter;

import 'vibrancy.dart';
import 'vibrancy_matrices.dart';

/// The material a vibrant widget sits on, as `UIBlurEffect.Style`'s system
/// materials name them.
///
/// UIKit tunes each [VibrancyStyle] to the material beneath it, thinner
/// materials letting more of the backdrop's colour through. The material
/// only picks the tuning: a [Vibrancy] does not blur, and reads whatever is
/// painted behind it, usually a blur of the app's own.
enum VibrancyMaterial {
  /// `UIBlurEffect.Style.systemUltraThinMaterial`, SwiftUI's
  /// `.ultraThinMaterial`.
  ultraThin,

  /// `UIBlurEffect.Style.systemThinMaterial`, SwiftUI's `.thinMaterial`.
  thin,

  /// `UIBlurEffect.Style.systemMaterial`, SwiftUI's `.regularMaterial`.
  regular,

  /// `UIBlurEffect.Style.systemThickMaterial`, SwiftUI's `.thickMaterial`.
  thick,

  /// `UIBlurEffect.Style.systemChromeMaterial`, SwiftUI's `.bar`.
  chrome,
}

/// The role of vibrant content, as `UIVibrancyEffectStyle` names it.
///
/// Each style but [label] recolours its content from the backdrop: a pixel's
/// colour is a fixed colour matrix applied to what lies behind it, and only
/// its alpha comes from the content. The matrix depends on the
/// [VibrancyMaterial] beneath and the brightness, and is the one UIKit
/// applies.
///
/// A [Vibrancy] applies a style to a live backdrop. Where the backdrop is a
/// known colour, [colorOver] gives the colour directly:
///
/// ```dart
/// final color = VibrancyStyle.secondaryLabel.colorOver(const Color(0xFFDCEAFE));
/// ```
enum VibrancyStyle {
  /// Primary text. UIKit draws it in the content's own colour, with no
  /// vibrancy.
  label,

  /// Secondary text: subtitles, captions, eyebrows.
  secondaryLabel,

  /// Tertiary text: placeholders and disabled text.
  tertiaryLabel,

  /// Quaternary text: watermarks.
  quaternaryLabel,

  /// Fills for thin and small shapes, such as a slider's track.
  fill,

  /// Fills for medium-size shapes, such as a switch's background.
  secondaryFill,

  /// Fills for large shapes, such as a text field or a button.
  tertiaryFill,

  /// Separators and hairlines.
  separator;

  /// The colour this style takes over [backdrop], a colour on [material] in
  /// [brightness], or null for [label], which UIKit draws in the content's
  /// own colour.
  Color? colorOver(
    Color backdrop, {
    VibrancyMaterial material = VibrancyMaterial.regular,
    Brightness brightness = Brightness.light,
  }) {
    final matrix = vibrancyMatrix(this, material, brightness);
    if (matrix == null) {
      return null;
    }
    final rgb = <double>[backdrop.r, backdrop.g, backdrop.b];
    double channel(int row) {
      final r = matrix.rows;
      final i = row * 4;
      return (r[i] * rgb[0] + r[i + 1] * rgb[1] + r[i + 2] * rgb[2] + r[i + 3])
          .clamp(0.0, 1.0);
    }

    return Color.from(
      alpha: 1,
      red: channel(0),
      green: channel(1),
      blue: channel(2),
    );
  }

  /// The colour filter UIKit applies to the backdrop for this style on
  /// [material] in [brightness], or null for [label], which UIKit draws as
  /// it is.
  ///
  /// [Vibrancy] applies it to the live backdrop; use it directly to give an
  /// image or a picture the same treatment, through a `ColorFiltered`.
  ColorFilter? colorFilter({
    VibrancyMaterial material = VibrancyMaterial.regular,
    Brightness brightness = Brightness.light,
  }) {
    return vibrancyMatrix(this, material, brightness)?.toColorFilter();
  }
}
