import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vibrancy/vibrancy.dart';

/// A full-screen page over a blurred photo: the photo, a wash of the
/// material's tint, and [child] in a [VibrancyScope] above them both.
///
/// The scope sits over the photo rather than around it, so the vibrant
/// widgets inside read the photo.
class Backdrop extends StatelessWidget {
  /// Creates a page over the photo at [asset].
  const Backdrop({
    super.key,
    required this.asset,
    required this.brightness,
    required this.vibrant,
    this.material = VibrancyMaterial.regular,
    required this.child,
  });

  /// The photo, already blurred.
  final String asset;

  /// The page's brightness, which also tunes the vibrancy.
  final Brightness brightness;

  /// Whether the [Vibrancy] widgets on the page apply the effect.
  final bool vibrant;

  /// The material the page's content sits on.
  final VibrancyMaterial material;

  /// The page's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: CupertinoTheme(
        data: CupertinoThemeData(brightness: brightness),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(asset, fit: BoxFit.cover),
            ColoredBox(
              color: dark ? const Color(0x59000000) : const Color(0x4DFFFFFF),
            ),
            VibrancyScope(
              material: material,
              brightness: brightness,
              enabled: vibrant,
              child: Builder(
                builder: (BuildContext context) {
                  final label = CupertinoColors.label.resolveFrom(context);
                  return IconTheme(
                    data: IconThemeData(color: label),
                    child: DefaultTextStyle(
                      style: CupertinoTheme.of(
                        context,
                      ).textTheme.textStyle.copyWith(color: label),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded shape filled with [color], for vibrant fills.
class Fill extends StatelessWidget {
  /// Creates a fill of [color] with [radius] corners.
  const Fill({
    super.key,
    required this.color,
    this.radius = 10,
    this.width,
    this.height,
  });

  /// The fill's colour without vibrancy.
  final CupertinoDynamicColor color;

  /// The corner radius.
  final double radius;

  /// The fill's width, or null to fill its parent.
  final double? width;

  /// The fill's height, or null to fill its parent.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.resolveFrom(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
