import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'vibrancy_matrices.dart';
import 'vibrancy_matrix.dart';
import 'vibrancy_style.dart';

/// Paints [child] in a colour drawn from whatever lies behind it, as UIKit's
/// `UIVibrancyEffect` does.
///
/// A label over a blurred sky picks up the sky's blue; over a blurred sunset
/// it turns warm. Each output pixel is the [style]'s colour matrix — the one
/// UIKit applies for that [material] and brightness — applied to the backdrop
/// at that pixel, and shown through [child]'s alpha. The child's own colour
/// is ignored, so a `Text` in any opaque colour gives the same result; only
/// its shape and opacity count.
///
/// [VibrancyStyle.label] draws [child] as it is, as UIKit does.
///
/// A [Vibrancy] does not blur. Put it over a blur of your own — an
/// `ImageFiltered` image, a [BackdropFilter] — inside a [VibrancyScope],
/// which gives the vibrant widgets below it a material and the backdrop they
/// all read.
///
/// ```dart
/// VibrancyScope(
///   material: VibrancyMaterial.regular,
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: <Widget>[
///       const Vibrancy(child: Text('PLACES')),
///       const Text('Sky Garden'),
///     ],
///   ),
/// )
/// ```
///
/// ## Performance
///
/// Reading the backdrop is the cost of the effect: on Impeller it ends the
/// render pass and copies the scene. Under a [VibrancyScope] the scene is
/// read once per style, however many [Vibrancy] widgets use it, and each of
/// them is one small offscreen layer and one textured draw. A [Vibrancy]
/// with no scope reads the backdrop for itself.
///
/// On Impeller a [Vibrancy] can sit under an [Opacity] or a
/// `FadeTransition`, and its child can have layers of its own, as long as
/// its [VibrancyScope] is outside the fading ancestor: a backdrop is read
/// from the layer it is in. Elsewhere, where a [Vibrancy] reads the backdrop
/// itself, fade it from outside, and a child that needs compositing of its
/// own — under a [RepaintBoundary], say — is painted as it is.
class Vibrancy extends StatelessWidget {
  /// Creates a vibrant [child].
  ///
  /// The [style] defaults to [VibrancyStyle.secondaryLabel], as
  /// `UIVibrancyEffect(blurEffect:)` does. [material] and [brightness]
  /// default to the nearest [VibrancyScope]'s, then to
  /// [VibrancyMaterial.regular] and the platform's brightness.
  const Vibrancy({
    super.key,
    this.style = VibrancyStyle.secondaryLabel,
    this.material,
    this.brightness,
    this.enabled = true,
    required this.child,
  });

  /// The role of [child], which picks its colour matrix.
  final VibrancyStyle style;

  /// The material [child] sits on, or null for the nearest
  /// [VibrancyScope]'s.
  final VibrancyMaterial? material;

  /// The brightness to tune for, or null for the nearest [VibrancyScope]'s,
  /// then the platform's, as UIKit follows the system's interface style.
  final Brightness? brightness;

  /// Whether to apply the effect. When false, or when the nearest
  /// [VibrancyScope] is disabled, [child] is drawn as it is.
  ///
  /// Prefer this to removing the [Vibrancy], which would rebuild [child].
  /// Give the child the colour it should have without vibrancy —
  /// `CupertinoColors.secondaryLabel` for a secondary label, say — and it
  /// falls back to that.
  final bool enabled;

  /// The content, used for its shape and opacity.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_VibrancyScopeData>();
    final matrix = vibrancyMatrix(
      style,
      material ?? scope?.scope.material ?? VibrancyMaterial.regular,
      brightness ??
          scope?.scope.brightness ??
          MediaQuery.maybePlatformBrightnessOf(context) ??
          Brightness.light,
    );
    return _Vibrancy(
      matrix: enabled && (scope?.scope.enabled ?? true) ? matrix : null,
      backdrops: scope?.backdrops,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<VibrancyStyle>('style', style));
    properties.add(
      EnumProperty<VibrancyMaterial>('material', material, defaultValue: null),
    );
    properties.add(
      EnumProperty<Brightness>('brightness', brightness, defaultValue: null),
    );
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
  }
}

/// The surface vibrant widgets sit on: the material they are tuned to, and
/// the backdrop they read.
///
/// The counterpart of the `UIVisualEffectView` whose blur a
/// `UIVibrancyEffect` is made from. As in UIKit, the backdrop is what was
/// painted before the scope — the blur beneath it — and not the scope's own
/// content: a [Vibrancy] over a card's background inside the scope reads
/// what lies under the card. Put the scope directly over the blur it
/// describes.
///
/// The scope reads the backdrop once for each style its [Vibrancy] widgets
/// use, so wrap as large a surface in one scope as shares a blur: a whole
/// scrolling page over a fixed photo costs one read per style.
///
/// A backdrop is read from the layer it is in, so keep the scope outside any
/// [Opacity], `FadeTransition` or `ShaderMask` that its content animates
/// through. Inside one, the scope would read that layer rather than the
/// blur. Fade the content below the scope instead:
///
/// ```dart
/// VibrancyScope(
///   child: FadeTransition(opacity: animation, child: details),
/// )
/// ```
class VibrancyScope extends StatefulWidget {
  /// Creates a scope of [material] for the [Vibrancy] widgets below it.
  const VibrancyScope({
    super.key,
    this.material = VibrancyMaterial.regular,
    this.brightness,
    this.enabled = true,
    required this.child,
  });

  /// The material the [Vibrancy] widgets below are tuned to.
  final VibrancyMaterial material;

  /// The brightness to tune for, or null for the platform's
  /// ([MediaQueryData.platformBrightness]). Set it when the app's theme
  /// differs from the platform's.
  final Brightness? brightness;

  /// Whether the [Vibrancy] widgets below apply the effect. When false they
  /// draw their children as they are and the backdrop is not read.
  final bool enabled;

  /// The surface's content.
  final Widget child;

  /// The nearest [VibrancyScope], or null if there is none.
  static VibrancyScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_VibrancyScopeData>()
        ?.scope;
  }

  @override
  State<VibrancyScope> createState() => _VibrancyScopeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<VibrancyMaterial>('material', material));
    properties.add(
      EnumProperty<Brightness>('brightness', brightness, defaultValue: null),
    );
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
  }
}

class _VibrancyScopeState extends State<VibrancyScope> {
  final _VibrancyBackdrops _backdrops = _VibrancyBackdrops();

  @override
  Widget build(BuildContext context) {
    return _VibrancyScopeData(
      scope: widget,
      backdrops: _backdrops,
      child: _VibrancyBackdrop(backdrops: _backdrops, child: widget.child),
    );
  }
}

class _VibrancyScopeData extends InheritedWidget {
  const _VibrancyScopeData({
    required this.scope,
    required this.backdrops,
    required super.child,
  });

  final VibrancyScope scope;
  final _VibrancyBackdrops backdrops;

  @override
  bool updateShouldNotify(_VibrancyScopeData oldWidget) {
    return scope.material != oldWidget.scope.material ||
        scope.brightness != oldWidget.scope.brightness ||
        scope.enabled != oldWidget.scope.enabled;
  }
}

/// Whether backdrop filters write into the scene and can share one read of
/// it through a [BackdropKey], as on Impeller, rather than starting a layer
/// that holds the filtered backdrop, as on Skia.
bool get _sharesBackdrops => ui.ImageFilter.isShaderFilterSupported;

/// The matrices the [Vibrancy] widgets of one scope use, each with the key
/// of its shared backdrop.
class _VibrancyBackdrops {
  /// Called when a matrix gains its first user or loses its last.
  VoidCallback? onChanged;

  final Map<VibrancyMatrix, BackdropKey> _keys =
      <VibrancyMatrix, BackdropKey>{};
  final Map<VibrancyMatrix, int> _users = <VibrancyMatrix, int>{};

  Iterable<VibrancyMatrix> get matrices => _users.keys;

  // The engine filters a shared backdrop once, so only widgets applying the
  // same matrix may share it.
  BackdropKey keyFor(VibrancyMatrix matrix) =>
      _keys.putIfAbsent(matrix, BackdropKey.new);

  void add(VibrancyMatrix matrix) {
    final users = _users[matrix] ?? 0;
    _users[matrix] = users + 1;
    if (users == 0) {
      onChanged?.call();
    }
  }

  void remove(VibrancyMatrix matrix) {
    final users = _users[matrix]! - 1;
    if (users > 0) {
      _users[matrix] = users;
      return;
    }
    _users.remove(matrix);
    onChanged?.call();
  }
}

final Map<VibrancyMatrix, ui.ColorFilter> _colorFilters =
    <VibrancyMatrix, ui.ColorFilter>{};

/// Sets [layer] up to draw [matrix] applied to the backdrop with
/// [blendMode].
BackdropFilterLayer _backdropLayer(
  BackdropFilterLayer? layer,
  VibrancyMatrix matrix,
  BackdropKey? key,
  BlendMode blendMode,
) {
  return (layer ?? BackdropFilterLayer())
    ..filter = _colorFilters.putIfAbsent(matrix, matrix.toColorFilter)
    ..blendMode = blendMode
    ..backdropKey = key;
}

/// An identity colour filter, for a layer that groups its children into one
/// offscreen pass: the engine elides an identity image filter but keeps an
/// identity colour filter, and saves a single layer for all of the children
/// it is applied to.
const ui.ColorFilter _group = ui.ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
]);

class _VibrancyBackdrop extends SingleChildRenderObjectWidget {
  const _VibrancyBackdrop({required this.backdrops, super.child});

  final _VibrancyBackdrops backdrops;

  @override
  _RenderVibrancyBackdrop createRenderObject(BuildContext context) {
    return _RenderVibrancyBackdrop(backdrops);
  }
}

// Reads the backdrop for each matrix a scope uses, before the scope's
// content paints.
//
// On Impeller, the first backdrop filter with a given BackdropKey in a frame
// copies the scene and filters it; every later one with the same key draws
// from that copy with its own blend mode, without reading the scene again
// (Canvas::SaveLayer in impeller/display_list/canvas.cc). This box draws that
// first one over its bounds, with BlendMode.dstOver, which changes nothing in
// the opaque scene: the copy is then of the backdrop alone, taken in the
// scope's own pass, before any of its content paints. (BlendMode.dst would
// say so more plainly, but the display list drops a layer that draws with
// it.)
class _RenderVibrancyBackdrop extends RenderProxyBox {
  _RenderVibrancyBackdrop(this._backdrops);

  final _VibrancyBackdrops _backdrops;

  final Map<VibrancyMatrix, LayerHandle<ClipRectLayer>> _clipLayers =
      <VibrancyMatrix, LayerHandle<ClipRectLayer>>{};
  final Map<VibrancyMatrix, LayerHandle<BackdropFilterLayer>> _filterLayers =
      <VibrancyMatrix, LayerHandle<BackdropFilterLayer>>{};

  void _matricesChanged() {
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _backdrops.onChanged = _matricesChanged;
  }

  @override
  void detach() {
    _backdrops.onChanged = null;
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing =>
      _sharesBackdrops && _backdrops.matrices.isNotEmpty;

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final matrix in _clipLayers.keys.toList()) {
      if (!_sharesBackdrops || !_backdrops.matrices.contains(matrix)) {
        _clipLayers.remove(matrix)!.layer = null;
        _filterLayers.remove(matrix)!.layer = null;
      }
    }
    if (_sharesBackdrops) {
      for (final matrix in _backdrops.matrices) {
        final clip = _clipLayers.putIfAbsent(
          matrix,
          LayerHandle<ClipRectLayer>.new,
        );
        final filter = _filterLayers.putIfAbsent(
          matrix,
          LayerHandle<BackdropFilterLayer>.new,
        );
        clip.layer = context.pushClipRect(
          needsCompositing,
          offset,
          Offset.zero & size,
          (PaintingContext context, Offset offset) {
            filter.layer = _backdropLayer(
              filter.layer,
              matrix,
              _backdrops.keyFor(matrix),
              BlendMode.dstOver,
            );
            context.pushLayer(filter.layer!, (_, _) {}, offset);
          },
          oldLayer: clip.layer,
        );
      }
    }
    super.paint(context, offset);
  }

  @override
  void dispose() {
    for (final handle in <LayerHandle<Layer>>[
      ..._clipLayers.values,
      ..._filterLayers.values,
    ]) {
      handle.layer = null;
    }
    super.dispose();
  }
}

class _Vibrancy extends SingleChildRenderObjectWidget {
  const _Vibrancy({required this.matrix, required this.backdrops, super.child});

  final VibrancyMatrix? matrix;
  final _VibrancyBackdrops? backdrops;

  @override
  _RenderVibrancy createRenderObject(BuildContext context) {
    return _RenderVibrancy(matrix: matrix, backdrops: backdrops);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderVibrancy renderObject) {
    renderObject
      ..matrix = matrix
      ..backdrops = backdrops;
  }
}

// Paints its child in the colour of a VibrancyMatrix applied to the
// backdrop, through the child's alpha: a backdrop pixel b under child alpha a
// becomes b * (1 - a) + matrix(b) * a.
//
// On Impeller, the box is a layer of its own (a group of the identity colour
// filter). The child paints into it as it is, then the filtered backdrop,
// read once by the scope (or by this box, with no scope), is drawn over it
// with BlendMode.srcIn, leaving matrix(b) * a. The layer then composites
// over whatever is beneath it like any other content, so the box can sit
// under an Opacity, a FadeTransition or a ShaderMask, and the child can
// have layers of its own.
//
// Elsewhere a backdrop filter starts a layer that holds the filtered
// backdrop, so the child is composited into it with BlendMode.dstIn, keeping
// the filtered backdrop only as far as the child is opaque.
class _RenderVibrancy extends RenderProxyBox {
  _RenderVibrancy({this._matrix, this._backdrops});

  VibrancyMatrix? get matrix => _matrix;
  VibrancyMatrix? _matrix;
  set matrix(VibrancyMatrix? value) {
    if (value == _matrix) {
      return;
    }
    _unregister();
    final wasActive = _matrix != null;
    _matrix = value;
    _register();
    if (wasActive != (value != null)) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  _VibrancyBackdrops? get backdrops => _backdrops;
  _VibrancyBackdrops? _backdrops;
  set backdrops(_VibrancyBackdrops? value) {
    if (value == _backdrops) {
      return;
    }
    _unregister();
    _backdrops = value;
    _register();
    markNeedsPaint();
  }

  // The key of this box's own backdrop read, when it has no scope.
  final BackdropKey _ownKey = BackdropKey();

  final LayerHandle<BackdropFilterLayer> _ownBackdropLayer =
      LayerHandle<BackdropFilterLayer>();
  final LayerHandle<ColorFilterLayer> _groupLayer =
      LayerHandle<ColorFilterLayer>();
  final LayerHandle<BackdropFilterLayer> _filterLayer =
      LayerHandle<BackdropFilterLayer>();

  void _register() {
    final matrix = _matrix;
    if (attached && matrix != null) {
      _backdrops?.add(matrix);
    }
  }

  void _unregister() {
    final matrix = _matrix;
    if (attached && matrix != null) {
      _backdrops?.remove(matrix);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _register();
  }

  @override
  void detach() {
    _unregister();
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _matrix != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    final matrix = _matrix;
    // Without shared backdrops the child is drawn as a mask in the filter's
    // canvas, which a composited child cannot be, so it is painted as it is.
    if (child == null ||
        matrix == null ||
        (!_sharesBackdrops && child.needsCompositing)) {
      layer = null;
      _ownBackdropLayer.layer = null;
      _groupLayer.layer = null;
      _filterLayer.layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      PaintingContext context,
      Offset offset,
    ) {
      if (!_sharesBackdrops) {
        _groupLayer.layer = null;
        _filterLayer.layer = _backdropLayer(
          _filterLayer.layer,
          matrix,
          null,
          BlendMode.srcOver,
        );
        context.pushLayer(_filterLayer.layer!, _paintMask, offset);
        return;
      }
      final backdrops = _backdrops;
      final BackdropKey key;
      if (backdrops == null) {
        key = _ownKey;
        _ownBackdropLayer.layer = _backdropLayer(
          _ownBackdropLayer.layer,
          matrix,
          key,
          BlendMode.dstOver,
        );
        context.pushLayer(_ownBackdropLayer.layer!, (_, _) {}, offset);
      } else {
        key = backdrops.keyFor(matrix);
        _ownBackdropLayer.layer = null;
      }
      _groupLayer.layer = context.pushColorFilter(offset, _group, (
        PaintingContext context,
        Offset offset,
      ) {
        context.paintChild(child, offset);
        _filterLayer.layer = _backdropLayer(
          _filterLayer.layer,
          matrix,
          key,
          BlendMode.srcIn,
        );
        context.pushLayer(_filterLayer.layer!, (_, _) {}, offset);
      }, oldLayer: _groupLayer.layer);
    }, oldLayer: layer as ClipRectLayer?);
  }

  void _paintMask(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.saveLayer(offset & size, Paint()..blendMode = BlendMode.dstIn);
    context.paintChild(child!, offset);
    canvas.restore();
  }

  @override
  void dispose() {
    _ownBackdropLayer.layer = null;
    _groupLayer.layer = null;
    _filterLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<VibrancyMatrix>('matrix', matrix, defaultValue: null),
    );
  }
}
