import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/catalog/fallback_art.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _coverRadius = AppDesign.coverRadius;
const _defaultHeight = 170.0;

/// Remote image with a bundled fallback. [seed] (usually the slug) picks the
/// fallback so one item always shows the same picture.
class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    this.url,
    this.seed = '',
    this.height = _defaultHeight,
    this.width,
  });

  final String? url;
  final String seed;
  final double height;
  final double? width;

  /// Android blocks cleartext by default, so only https is loaded.
  bool get _loadable => url != null && url!.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      fallbackArtFor(seed),
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(_coverRadius),
      child: _loadable
          ? Image.network(
              url!,
              height: height,
              width: width ?? double.infinity,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : SizedBox(
                      height: height,
                      width: width ?? double.infinity,
                      child: const ColoredBox(color: AppDesign.line),
                    ),
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}
