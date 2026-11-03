import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _artGap = 24.0;
const _linkGap = 4.0;

/// Square artwork, episode title and the tappable series line.
class PlayerTrackInfo extends StatelessWidget {
  const PlayerTrackInfo({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) => CoverArt(
              url: episode.seriesCoverUrl,
              seed: episode.seriesSlug,
              height: constraints.maxHeight,
              width: constraints.maxWidth,
            ),
          ),
        ),
        const SizedBox(height: _artGap),
        Text(
          episode.title,
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: _linkGap),
        TextButton(
          onPressed: () =>
              context.push(AppRoutes.seriesFor(episode.seriesSlug)),
          child: Text(l.playerSeriesLine(episode.seriesTitle)),
        ),
      ],
    );
  }
}
