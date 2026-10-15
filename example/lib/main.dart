import 'package:flutter/cupertino.dart';

import 'pages/place_page.dart';
import 'pages/player_page.dart';
import 'pages/settings_page.dart';
import 'pages/styles_page.dart';

void main() => runApp(const VibrancyGallery());

/// Four pages over blurred photos — swipe between them, and switch vibrancy
/// off to see the flat grey that Flutter's own colours give.
class VibrancyGallery extends StatefulWidget {
  /// Creates the gallery.
  const VibrancyGallery({super.key});

  @override
  State<VibrancyGallery> createState() => _VibrancyGalleryState();
}

class _VibrancyGalleryState extends State<VibrancyGallery> {
  bool _vibrant = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Vibrancy',
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: <Widget>[
          PageView(
            children: <Widget>[
              PlacePage(vibrant: _vibrant),
              PlayerPage(vibrant: _vibrant),
              SettingsPage(vibrant: _vibrant),
              StylesPage(vibrant: _vibrant),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Center(
                child: _VibrancySwitch(
                  value: _vibrant,
                  onChanged: (bool value) => setState(() => _vibrant = value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VibrancySwitch extends StatelessWidget {
  const _VibrancySwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Vibrancy',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              CupertinoSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
