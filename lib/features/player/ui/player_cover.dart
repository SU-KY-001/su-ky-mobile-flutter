import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

/// Large square series artwork, centred.
class PlayerCover extends StatelessWidget {
  const PlayerCover({super.key, required this.episode, required this.side});

  final EpisodeDetail episode;
  final double side;

  @override
  Widget build(BuildContext context) => Center(
    child: CoverArt(
      url: episode.seriesCoverUrl,
      seed: episode.seriesSlug,
      height: side,
      width: side,
    ),
  );
}
