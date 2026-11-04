import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _titleSize = 22.0;
const _lineGap = 4.0;
const _titleMaxLines = 2;

/// Left-aligned episode title with the series name under it.
class PlayerTrackInfo extends StatelessWidget {
  const PlayerTrackInfo({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        episode.title,
        maxLines: _titleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: context.text.titleLarge?.copyWith(
          fontSize: _titleSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: _lineGap),
      Text(
        episode.seriesTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
      ),
    ],
  );
}
