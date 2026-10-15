import 'package:flutter/cupertino.dart';
import 'package:vibrancy/vibrancy.dart';

import 'backdrop.dart';

/// A grouped settings list over a blurred city at night.
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const SettingsPage({super.key, this.vibrant = true});

  /// Whether the page's vibrant widgets apply the effect.
  final bool vibrant;

  @override
  Widget build(BuildContext context) {
    return Backdrop(
      asset: 'assets/night.jpg',
      brightness: Brightness.dark,
      material: VibrancyMaterial.thick,
      vibrant: vibrant,
      child: Builder(
        builder: (BuildContext context) {
          final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 120),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 20),
                  child: Text(
                    'Focus',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                  ),
                ),
                const _Group(
                  rows: <_Row>[
                    _Row(
                      CupertinoIcons.moon_fill,
                      Color(0xFF5E5CE6),
                      'Do Not Disturb',
                      'On',
                    ),
                    _Row(
                      CupertinoIcons.person_fill,
                      Color(0xFF0A84FF),
                      'Personal',
                      'Set Up',
                    ),
                    _Row(
                      CupertinoIcons.bed_double_fill,
                      Color(0xFF30D158),
                      'Sleep',
                      '23:00',
                    ),
                    _Row(
                      CupertinoIcons.briefcase_fill,
                      Color(0xFFFF9F0A),
                      'Work',
                      'Off',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Vibrancy(
                    child: Text(
                      'Focus lets you customise your device and silence notifications '
                      'to minimise distractions.',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const _Group(
                  rows: <_Row>[
                    _Row(
                      CupertinoIcons.device_phone_portrait,
                      Color(0xFF8E8E93),
                      'Share Across Devices',
                      'On',
                    ),
                    _Row(
                      CupertinoIcons.bell_fill,
                      Color(0xFFFF375F),
                      'Focus Status',
                      'On',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row(this.icon, this.tint, this.title, this.value);

  final IconData icon;
  final Color tint;
  final String title;
  final String value;
}

class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: Vibrancy(
            style: VibrancyStyle.tertiaryFill,
            child: Fill(color: CupertinoColors.tertiarySystemFill, radius: 12),
          ),
        ),
        Column(
          children: <Widget>[
            for (final (int index, _Row row) in rows.indexed) ...<Widget>[
              if (index > 0)
                const Padding(
                  padding: EdgeInsets.only(left: 58),
                  child: Vibrancy(
                    style: VibrancyStyle.separator,
                    child: Fill(
                      color: CupertinoColors.separator,
                      radius: 0,
                      height: 0.5,
                    ),
                  ),
                ),
              SizedBox(
                height: 52,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: row.tint,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: SizedBox.square(
                        dimension: 30,
                        child: Icon(
                          row.icon,
                          size: 18,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        row.title,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Vibrancy(
                      child: Text(
                        row.value,
                        style: TextStyle(color: secondary, fontSize: 17),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Vibrancy(
                      style: VibrancyStyle.tertiaryLabel,
                      child: Icon(
                        CupertinoIcons.chevron_forward,
                        size: 16,
                        color: tertiary,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
