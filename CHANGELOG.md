# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the package
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-10-15

### Fixed

- On Impeller, a `Vibrancy` under an `Opacity`, a `FadeTransition` or a
  `ShaderMask` fades its child instead of filling its whole box with the
  vibrant colour. Each `Vibrancy` is now composited in a layer of its own.
- On Impeller, a `Vibrancy` whose child has compositing layers of its own,
  such as a `RepaintBoundary`, is vibrant instead of drawn as it is.

## [0.1.0] - 2026-10-15

### Added

- `Vibrancy`, which paints its child in a colour drawn from the backdrop with
  the colour matrix UIKit applies for its style, material and brightness.
- `VibrancyScope`, which sets the material, brightness and on/off state for
  the vibrant widgets below it and reads the backdrop once per style for all
  of them.
- `VibrancyStyle` and `VibrancyMaterial`, with the matrices of every style
  over every system material, light and dark, read out of UIKit on iOS 27.0.
- `VibrancyStyle.colorOver` and `VibrancyStyle.colorFilter`, for a known
  backdrop colour or an image.
