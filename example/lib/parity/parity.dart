import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:vibrancy/vibrancy.dart';

/// Launch-environment switches shared with the native harness in `native/`,
/// so one script (`tools/parity/capture.sh`) configures both: `VIB_SCENE`
/// picks the page, `VIB_BLUR` the material, `VIB_STYLE` the swatch page's
/// style and `VIB_DARK` the brightness. Dart cannot read the launch
/// environment on iOS, so the Runner hands it over.
abstract final class Parity {
  static const MethodChannel _channel = MethodChannel(
    'vibrancy.example/parity',
  );

  /// The page to open on.
  static String scene = 'demo';

  /// The material the pages are tuned to.
  static VibrancyMaterial material = VibrancyMaterial.regular;

  /// The style of the swatch page's squares.
  static VibrancyStyle style = VibrancyStyle.secondaryLabel;

  /// The brightness to draw in.
  static Brightness brightness = Brightness.light;

  /// The opacity of the fade page's content.
  static double fade = 1;

  /// Whether the fade page leaves its content out.
  static bool hide = false;

  /// Whether the benchmark page draws its content without vibrancy.
  static bool perfOff = false;

  /// Whether the benchmark page draws every vibrant piece in one style.
  static bool perfOneStyle = false;

  /// Reads the switches from the launch environment.
  static Future<void> load() async {
    var environment = Platform.environment;
    if (Platform.isIOS) {
      try {
        final handed = await _channel.invokeMapMethod<String, String>(
          'environment',
        );
        if (handed != null) {
          environment = handed;
        }
      } on MissingPluginException {
        // Not running in the example's own Runner.
      }
    }
    scene = environment['VIB_SCENE'] ?? scene;
    material =
        VibrancyMaterial.values.asNameMap()[environment['VIB_BLUR']] ??
        material;
    style = VibrancyStyle.values.asNameMap()[environment['VIB_STYLE']] ?? style;
    brightness = environment['VIB_DARK'] == '1'
        ? Brightness.dark
        : Brightness.light;
    perfOff = environment['VIB_PERF_OFF'] == '1';
    fade = double.tryParse(environment['VIB_FADE'] ?? '') ?? 1;
    hide = environment['VIB_HIDE'] == '1';
    perfOneStyle = environment['VIB_PERF_ONE'] == '1';
  }
}
