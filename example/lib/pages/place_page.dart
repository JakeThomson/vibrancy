import 'package:flutter/cupertino.dart';
import 'package:vibrancy/vibrancy.dart';

import 'backdrop.dart';

/// A saved place over a blurred photo of the sky.
class PlacePage extends StatelessWidget {
  /// Creates the place page.
  const PlacePage({super.key, this.vibrant = true});

  /// Whether the page's vibrant widgets apply the effect.
  final bool vibrant;

  @override
  Widget build(BuildContext context) {
    return Backdrop(
      asset: 'assets/sky.jpg',
      brightness: Brightness.light,
      vibrant: vibrant,
      child: Builder(
        builder: (BuildContext context) {
          final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
          final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 120),
              children: <Widget>[
                Vibrancy(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 13,
                        color: secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PLACES',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sky Garden',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 8,
                  children: <Widget>[
                    _Chip('Scenic spot'),
                    _Chip('★ 4.6'),
                    _Chip('Free entry'),
                  ],
                ),
                const SizedBox(height: 20),
                Vibrancy(
                  child: Text(
                    'Known as the Walkie Talkie for its unique shape, this skyscraper '
                    'tops out in a three-storey garden with a restaurant and views '
                    'across the City.',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 17,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Vibrancy(
                  style: VibrancyStyle.tertiaryLabel,
                  child: Text(
                    'Saved about a year ago',
                    style: TextStyle(color: tertiary, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),
                const Vibrancy(
                  style: VibrancyStyle.separator,
                  child: Fill(
                    color: CupertinoColors.separator,
                    radius: 0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const _Detail(
                  icon: CupertinoIcons.map,
                  text: '20 Fenchurch St, London',
                ),
                const _Detail(
                  icon: CupertinoIcons.clock,
                  text: 'Open today, 10:00 – 18:00',
                ),
                const _Detail(
                  icon: CupertinoIcons.ticket,
                  text: 'Book a free slot in advance',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: Vibrancy(
            style: VibrancyStyle.tertiaryFill,
            child: Fill(color: CupertinoColors.tertiarySystemFill, radius: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Vibrancy(child: Icon(icon, size: 20, color: secondary)),
          const SizedBox(width: 14),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
