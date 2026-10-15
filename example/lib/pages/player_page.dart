import 'package:flutter/cupertino.dart';
import 'package:vibrancy/vibrancy.dart';

import 'backdrop.dart';

/// A now-playing screen over its own artwork, blurred.
class PlayerPage extends StatelessWidget {
  /// Creates the player page.
  const PlayerPage({super.key, this.vibrant = true});

  /// Whether the page's vibrant widgets apply the effect.
  final bool vibrant;

  @override
  Widget build(BuildContext context) {
    return Backdrop(
      asset: 'assets/sunset.jpg',
      brightness: Brightness.dark,
      material: VibrancyMaterial.thin,
      vibrant: vibrant,
      child: Builder(
        builder: (BuildContext context) {
          final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
          final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 96),
              child: Column(
                children: <Widget>[
                  const Vibrancy(
                    style: VibrancyStyle.tertiaryFill,
                    child: Fill(
                      color: CupertinoColors.tertiarySystemFill,
                      radius: 3,
                      width: 40,
                      height: 5,
                    ),
                  ),
                  const Spacer(),
                  AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 30,
                            offset: Offset(0, 16),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/sunset.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment(0, -0.6),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Golden Hour',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Vibrancy(
                              child: Text(
                                'The Lumens',
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Vibrancy(
                        style: VibrancyStyle.secondaryFill,
                        child: Icon(
                          CupertinoIcons.ellipsis_circle_fill,
                          size: 30,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Track(progress: 0.36, height: 6),
                  const SizedBox(height: 8),
                  Vibrancy(
                    style: VibrancyStyle.tertiaryLabel,
                    child: Row(
                      children: <Widget>[
                        Text(
                          '1:24',
                          style: TextStyle(
                            color: tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '-2:31',
                          style: TextStyle(
                            color: tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(CupertinoIcons.backward_fill, size: 38),
                      Icon(CupertinoIcons.pause_fill, size: 52),
                      Icon(CupertinoIcons.forward_fill, size: 38),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: <Widget>[
                      Vibrancy(
                        child: Icon(
                          CupertinoIcons.speaker_fill,
                          size: 16,
                          color: secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _Track(progress: 0.6, height: 6)),
                      const SizedBox(width: 12),
                      Vibrancy(
                        child: Icon(
                          CupertinoIcons.speaker_3_fill,
                          size: 16,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A slider's track: a vibrant fill, with the played part in the label
/// colour over it.
class _Track extends StatelessWidget {
  const _Track({required this.progress, required this.height});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Vibrancy(
            style: VibrancyStyle.fill,
            child: Fill(color: CupertinoColors.systemFill, radius: 3),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: const Fill(color: CupertinoColors.label, radius: 3),
          ),
        ],
      ),
    );
  }
}
