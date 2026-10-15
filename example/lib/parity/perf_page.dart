import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:vibrancy/vibrancy.dart';

import 'parity.dart';

/// Scrolls forty place cards, four vibrant pieces each, over a photo blurred
/// by the app, and logs the frame times (`PERF ...` in the device log).
///
/// With `VIB_PERF_OFF=1` the same page is drawn with every [Vibrancy]
/// disabled, for the baseline.
class PerfPage extends StatefulWidget {
  /// Creates the benchmark page.
  const PerfPage({super.key});

  @override
  State<PerfPage> createState() => _PerfPageState();
}

class _PerfPageState extends State<PerfPage> {
  final ScrollController _controller = ScrollController();
  final List<FrameTiming> _timings = <FrameTiming>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    SchedulerBinding.instance.addTimingsCallback(_timings.addAll);
    for (var pass = 0; pass < 3; pass++) {
      await _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(seconds: 3),
        curve: Curves.linear,
      );
      await _controller.animateTo(
        0,
        duration: const Duration(seconds: 3),
        curve: Curves.linear,
      );
    }
    SchedulerBinding.instance.removeTimingsCallback(_timings.addAll);
    double percentile(List<double> values, double p) {
      values.sort();
      return values[((values.length - 1) * p).round()];
    }

    final raster = <double>[
      for (final t in _timings) t.rasterDuration.inMicroseconds / 1000,
    ];
    final build = <double>[
      for (final t in _timings) t.buildDuration.inMicroseconds / 1000,
    ];
    debugPrint(
      'PERF vibrancy=${!Parity.perfOff} one=${Parity.perfOneStyle} frames=${_timings.length} '
      'raster p50=${percentile(raster, .5).toStringAsFixed(2)} p90=${percentile(raster, .9).toStringAsFixed(2)} '
      'p99=${percentile(raster, .99).toStringAsFixed(2)} '
      'build p50=${percentile(build, .5).toStringAsFixed(2)} p90=${percentile(build, .9).toStringAsFixed(2)}',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !Parity.perfOff;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: 30,
            sigmaY: 30,
            tileMode: TileMode.clamp,
          ),
          child: Image.asset('assets/sky.jpg', fit: BoxFit.cover),
        ),
        VibrancyScope(
          child: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            itemCount: 40,
            itemBuilder: (BuildContext context, int index) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Vibrancy(
                    enabled: enabled,
                    child: const Text(
                      'PLACES',
                      style: TextStyle(fontSize: 13, letterSpacing: 2),
                    ),
                  ),
                  Text(
                    'Place $index',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Vibrancy(
                    enabled: enabled,
                    child: const Text(
                      'Known as the walkie talkie due to its unique shape, this skyscraper features a top-floor restaurant.',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  Vibrancy(
                    enabled: enabled,
                    style: Parity.perfOneStyle
                        ? VibrancyStyle.secondaryLabel
                        : VibrancyStyle.tertiaryLabel,
                    child: const Text(
                      'Saved about a year ago',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Vibrancy(
                    enabled: enabled,
                    style: Parity.perfOneStyle
                        ? VibrancyStyle.secondaryLabel
                        : VibrancyStyle.separator,
                    child: const SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: ColoredBox(color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
