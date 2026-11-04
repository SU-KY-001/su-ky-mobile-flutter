import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _heroHeight = 220.0;
const _heroRadius = 16.0;

class SeriesHero extends StatelessWidget {
  const SeriesHero({super.key, required this.series});

  final SeriesDetail series;

  @override
  Widget build(BuildContext context) {
    final startYear = series.startYear;
    final endYear = series.endYear;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_heroRadius),
      child: Stack(
        children: [
          CoverArt(
            url: series.landscapeUrl ?? series.coverUrl,
            seed: series.slug,
            height: _heroHeight,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: .08), Colors.black87],
                ),
              ),
            ),
          ),
          if (startYear != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  endYear == null || endYear == startYear
                      ? '$startYear'
                      : '$startYear – $endYear',
                  style: const TextStyle(color: AppDesign.white, fontSize: 11),
                ),
              ),
            ),
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  style: context.text.titleLarge?.copyWith(
                    color: AppDesign.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (series.creatorName != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    series.creatorName!,
                    style: context.text.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
