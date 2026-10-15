import 'package:flutter/cupertino.dart';
import 'package:vibrancy/vibrancy.dart';

import 'parity.dart';

/// The native card page, frame for frame, over a capture of the native page
/// with its content hidden (`assets/parity/native-<material>-<brightness>-bare.png`).
class CardPage extends StatelessWidget {
  /// Creates the card page.
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    final Color ink = CupertinoColors.label.resolveFrom(context);
    Widget at(double x, double y, double w, double h, Widget child) =>
        Positioned(left: x, top: y, width: w, height: h, child: child);
    Widget vibrant(VibrancyStyle style, Widget child) =>
        Vibrancy(style: style, child: child);
    TextStyle font(
      double size, [
      FontWeight weight = FontWeight.w400,
      double spacing = 0,
    ]) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: ink,
      height: 1.2,
    );
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            'assets/parity/native-${Parity.material.name}-${Parity.brightness.name}-bare.png',
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fill(
          child: VibrancyScope(
            material: Parity.material,
            brightness: Parity.brightness,
            child: Stack(
              children: <Widget>[
                at(
                  24,
                  110,
                  200,
                  20,
                  vibrant(
                    VibrancyStyle.secondaryLabel,
                    Text('PLACES', style: font(13, FontWeight.w500, 2)),
                  ),
                ),
                at(
                  24,
                  134,
                  354,
                  42,
                  Text('Sky Garden', style: font(34, FontWeight.bold)),
                ),
                at(
                  24,
                  188,
                  110,
                  30,
                  vibrant(
                    VibrancyStyle.tertiaryFill,
                    const DecoratedBox(
                      decoration: ShapeDecoration(
                        color: white,
                        shape: StadiumBorder(),
                      ),
                    ),
                  ),
                ),
                at(
                  36,
                  193,
                  100,
                  20,
                  Text('Scenic spot', style: font(15, FontWeight.w500)),
                ),
                at(
                  24,
                  232,
                  354,
                  66,
                  vibrant(
                    VibrancyStyle.secondaryLabel,
                    Text(
                      'Known as the walkie talkie due to its unique shape, this skyscraper features a top-floor restaurant.',
                      style: font(17),
                    ),
                  ),
                ),
                at(
                  24,
                  310,
                  354,
                  20,
                  vibrant(
                    VibrancyStyle.tertiaryLabel,
                    Text('Saved about a year ago', style: font(15)),
                  ),
                ),
                at(
                  24,
                  344,
                  354,
                  1,
                  vibrant(
                    VibrancyStyle.separator,
                    const ColoredBox(color: white),
                  ),
                ),
                for (final (int index, VibrancyStyle style)
                    in VibrancyStyle.values.indexed) ...<Widget>[
                  at(
                    24,
                    364.0 + index * 52,
                    150,
                    40,
                    vibrant(style, const _Patch()),
                  ),
                  at(
                    190,
                    364.0 + index * 52 + 8,
                    190,
                    24,
                    vibrant(
                      style,
                      Text(style.name, style: font(20, FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The native swatch page: rows of solid backgrounds, each with a cell of
/// bare background and vibrant squares of white, black, red and
/// half-transparent white. With no material to emulate, the first cell is
/// the background itself.
class SwatchesPage extends StatelessWidget {
  /// Creates the swatch page.
  const SwatchesPage({super.key});

  static const List<int> _backgrounds = <int>[
    0xFFFFFF,
    0x000000,
    0x808080,
    0xD93025,
    0x1E8E3E,
    0x1A73E8,
    0x7FA7D9,
    0xF29900,
    0x8E44AD,
    0xF4D03F,
    0x16A085,
    0x8D6E63,
  ];

  static const List<Color?> _contents = <Color?>[
    null,
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFFF0000),
    Color(0x80FFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Stack(
        children: <Widget>[
          for (final (int row, int background) in _backgrounds.indexed)
            for (final (int column, Color? content) in _contents.indexed)
              Positioned(
                left: 26.0 + column * 70,
                top: 90.0 + row * 56,
                width: 70,
                height: 56,
                child: ColoredBox(
                  color: Color(0xFF000000 | background),
                  child: content == null
                      ? null
                      : Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 8),
                            child: Vibrancy(
                              style: Parity.style,
                              material: Parity.material,
                              brightness: Parity.brightness,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: ColoredBox(color: content),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Patch extends StatelessWidget {
  const _Patch();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 150,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
