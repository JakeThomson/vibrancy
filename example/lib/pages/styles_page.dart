import 'package:flutter/cupertino.dart';
import 'package:vibrancy/vibrancy.dart';

import 'backdrop.dart';

/// Every style over every material, in a list that scrolls over a spectrum,
/// so each row takes the colour of whatever it passes over.
class StylesPage extends StatelessWidget {
  /// Creates the styles page.
  const StylesPage({super.key, this.vibrant = true, this.controller});

  /// Whether the page's vibrant widgets apply the effect.
  final bool vibrant;

  /// The list's scroll controller.
  final ScrollController? controller;

  static const Map<VibrancyStyle, CupertinoDynamicColor> _colors =
      <VibrancyStyle, CupertinoDynamicColor>{
        VibrancyStyle.label: CupertinoColors.label,
        VibrancyStyle.secondaryLabel: CupertinoColors.secondaryLabel,
        VibrancyStyle.tertiaryLabel: CupertinoColors.tertiaryLabel,
        VibrancyStyle.quaternaryLabel: CupertinoColors.quaternaryLabel,
        VibrancyStyle.fill: CupertinoColors.systemFill,
        VibrancyStyle.secondaryFill: CupertinoColors.secondarySystemFill,
        VibrancyStyle.tertiaryFill: CupertinoColors.tertiarySystemFill,
        VibrancyStyle.separator: CupertinoColors.separator,
      };

  @override
  Widget build(BuildContext context) {
    return Backdrop(
      asset: 'assets/spectrum.jpg',
      brightness: Brightness.light,
      vibrant: vibrant,
      child: SafeArea(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 120),
          children: <Widget>[
            for (final material in VibrancyMaterial.values) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(
                  '${material.name[0].toUpperCase()}${material.name.substring(1)} material',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final style in VibrancyStyle.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Builder(
                    builder: (BuildContext context) {
                      final color = _colors[style]!;
                      return Row(
                        children: <Widget>[
                          Vibrancy(
                            style: style,
                            material: material,
                            child: Fill(color: color, width: 96, height: 32),
                          ),
                          const SizedBox(width: 16),
                          Vibrancy(
                            style: style,
                            material: material,
                            child: Text(
                              style.name,
                              style: TextStyle(
                                color:
                                    style.name.contains('Fill') ||
                                        style == VibrancyStyle.separator
                                    ? CupertinoColors.secondaryLabel
                                          .resolveFrom(context)
                                    : color.resolveFrom(context),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
