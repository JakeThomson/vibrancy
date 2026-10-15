import 'package:flutter/cupertino.dart';

import '../pages/place_page.dart';
import '../pages/player_page.dart';
import '../pages/settings_page.dart';
import '../pages/styles_page.dart';
import 'pages.dart';
import 'parity.dart';
import 'perf_page.dart';

/// The parity harness's entry point: one page, picked by `VIB_SCENE`, as
/// `tools/parity/capture.sh` asks for it.
///
///     flutter build ios --simulator --debug -t lib/parity/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parity.load();
  runApp(
    CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: Parity.brightness),
      home: switch (Parity.scene) {
        'swatches' => const SwatchesPage(),
        'card' => const CardPage(),
        'perf' => const PerfPage(),
        'place' => PlacePage(vibrant: !Parity.perfOff),
        'player' => PlayerPage(vibrant: !Parity.perfOff),
        'settings' => SettingsPage(vibrant: !Parity.perfOff),
        'scroll' => const _ScrollingStyles(),
        _ => StylesPage(vibrant: !Parity.perfOff),
      },
    ),
  );
}

/// The styles page scrolling on its own, slowly, for the README's recording.
class _ScrollingStyles extends StatefulWidget {
  const _ScrollingStyles();

  @override
  State<_ScrollingStyles> createState() => _ScrollingStylesState();
}

class _ScrollingStylesState extends State<_ScrollingStyles> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      await _controller.animateTo(
        900,
        duration: const Duration(seconds: 6),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      StylesPage(vibrant: !Parity.perfOff, controller: _controller);
}
