import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibrancy/src/vibrancy_matrices.dart';
import 'package:vibrancy/vibrancy.dart';

/// The 0-255 channels of `matrix` applied to `backdrop`, as UIKit computes
/// them.
List<int> _expected(List<double> rows, Color backdrop) {
  final rgb = <double>[backdrop.r, backdrop.g, backdrop.b];
  return <int>[
    for (var row = 0; row < 3; row++)
      ((rows[row * 4] * rgb[0] +
                      rows[row * 4 + 1] * rgb[1] +
                      rows[row * 4 + 2] * rgb[2] +
                      rows[row * 4 + 3])
                  .clamp(0.0, 1.0) *
              255)
          .round(),
  ];
}

Future<List<int>> _pixel(WidgetTester tester, GlobalKey key, Offset at) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    return image.toByteData(format: ui.ImageByteFormat.rawRgba);
  }))!;
  final width = boundary.size.width.toInt();
  final index = (at.dy.toInt() * width + at.dx.toInt()) * 4;
  return <int>[
    bytes.getUint8(index),
    bytes.getUint8(index + 1),
    bytes.getUint8(index + 2),
  ];
}

void main() {
  test('label draws as it is in every material and brightness', () {
    for (final material in VibrancyMaterial.values) {
      for (final brightness in Brightness.values) {
        expect(
          vibrancyMatrix(VibrancyStyle.label, material, brightness),
          isNull,
        );
      }
    }
  });

  test('every other style has a matrix in every material and brightness', () {
    for (final style in VibrancyStyle.values.skip(1)) {
      for (final material in VibrancyMaterial.values) {
        for (final brightness in Brightness.values) {
          expect(
            vibrancyMatrix(style, material, brightness)!.rows,
            hasLength(12),
          );
        }
      }
    }
  });

  test('the light regular secondary label is the matrix UIKit applies', () {
    // tools/parity/out/dump-light.txt, `regular / secondaryLabel`.
    expect(
      vibrancyMatrix(
        VibrancyStyle.secondaryLabel,
        VibrancyMaterial.regular,
        Brightness.light,
      )!.rows,
      <double>[
        1.55195, -0.8805, -0.16995, 0.04425, //
        -0.44778, 1.12044, -0.17116, 0.04425,
        -0.44899, -0.87868, 1.82917, 0.04425,
      ],
    );
  });

  group('VibrancyStyle.colorOver', () {
    // Pixels from the native swatch page (tools/parity): the material under a
    // vibrant square, and the square, in UIKit's own rendering.
    void expectNative(Color actual, int red, int green, int blue) {
      expect((actual.r * 255).round(), closeTo(red, 1));
      expect((actual.g * 255).round(), closeTo(green, 1));
      expect((actual.b * 255).round(), closeTo(blue, 1));
    }

    test('matches UIKit over a light material', () {
      expectNative(
        VibrancyStyle.secondaryLabel.colorOver(const Color(0xFFDCEAFF))!,
        102,
        132,
        174,
      );
    });

    test('matches UIKit over a dark material', () {
      expectNative(
        VibrancyStyle.secondaryLabel.colorOver(
          const Color(0xFF37465A),
          brightness: Brightness.dark,
        )!,
        149,
        173,
        203,
      );
    });

    test('is null for label, which is not vibrant', () {
      expect(VibrancyStyle.label.colorOver(const Color(0xFFDCEAFE)), isNull);
      expect(VibrancyStyle.label.colorFilter(), isNull);
    });
  });

  testWidgets('a scope reads what is painted before it, not its own content', (
    WidgetTester tester,
  ) async {
    const backdrop = Color(0xFF7FA7D9);
    final key = GlobalKey();
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          key: key,
          child: const ColoredBox(
            color: backdrop,
            child: VibrancyScope(
              child: SizedBox(
                width: 20,
                height: 20,
                child: Vibrancy(child: ColoredBox(color: Color(0xFF000000))),
              ),
            ),
          ),
        ),
      ),
    );
    final expected = VibrancyStyle.secondaryLabel.colorOver(backdrop)!;
    final pixel = await _pixel(tester, key, const Offset(10, 10));
    expect(pixel[0], closeTo((expected.r * 255).round(), 2));
    expect(pixel[1], closeTo((expected.g * 255).round(), 2));
    expect(pixel[2], closeTo((expected.b * 255).round(), 2));
  });

  testWidgets(
    'a vibrant child shows the matrix of the backdrop through its alpha',
    (WidgetTester tester) async {
      const backdrop = Color(0xFF7FA7D9);
      final key = GlobalKey();
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: key,
            child: const ColoredBox(
              color: backdrop,
              child: SizedBox(
                width: 60,
                height: 20,
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Vibrancy(
                      material: VibrancyMaterial.regular,
                      brightness: Brightness.light,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: ColoredBox(color: Color(0xFFFF0000)),
                      ),
                    ),
                    Vibrancy(
                      material: VibrancyMaterial.regular,
                      brightness: Brightness.light,
                      child: SizedBox(width: 20, height: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final rows = vibrancyMatrix(
        VibrancyStyle.secondaryLabel,
        VibrancyMaterial.regular,
        Brightness.light,
      )!.rows;
      final vibrant = await _pixel(tester, key, const Offset(10, 10));
      final expected = _expected(rows, backdrop);
      for (var channel = 0; channel < 3; channel++) {
        expect(
          vibrant[channel],
          closeTo(expected[channel], 2),
          reason: 'channel $channel of $vibrant',
        );
      }
      // An empty child leaves the backdrop alone.
      expect(await _pixel(tester, key, const Offset(30, 10)), <int>[
        0x7F,
        0xA7,
        0xD9,
      ]);
      expect(await _pixel(tester, key, const Offset(50, 10)), <int>[
        0x7F,
        0xA7,
        0xD9,
      ]);
    },
  );

  testWidgets('a disabled Vibrancy paints its child as it is', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          key: key,
          child: const ColoredBox(
            color: Color(0xFF7FA7D9),
            child: Vibrancy(
              enabled: false,
              child: SizedBox(
                width: 20,
                height: 20,
                child: ColoredBox(color: Color(0xFFFF0000)),
              ),
            ),
          ),
        ),
      ),
    );
    expect(await _pixel(tester, key, const Offset(10, 10)), <int>[0xFF, 0, 0]);
  });

  testWidgets('VibrancyScope sets the material and brightness below it', (
    WidgetTester tester,
  ) async {
    late VibrancyScope? scope;
    await tester.pumpWidget(
      VibrancyScope(
        material: VibrancyMaterial.thin,
        brightness: Brightness.dark,
        child: Builder(
          builder: (BuildContext context) {
            scope = VibrancyScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(scope?.material, VibrancyMaterial.thin);
    expect(scope?.brightness, Brightness.dark);
  });
}
