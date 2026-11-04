import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/expandable_description.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'player_sources.dart';

const _sectionGap = 24.0;
const _cardGap = 12.0;
const _metaGap = 8.0;
const _metaSeparator = ' · ';
const _eventRowHeight = 56.0;

/// "About this episode" block under the player controls: facts, description,
/// the historical event it covers and the cited sources. Each part is its own
/// card so the block reads as sections, and parts without data are omitted.
class PlayerAbout extends StatelessWidget {
  const PlayerAbout({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final description = episode.description;
    final event = episode.event;
    final publishedAt = episode.publishedAt;
    final start = episode.seriesStartYear;
    final end = episode.seriesEndYear;
    final facts = [
      if (publishedAt != null)
        l.playerReleased(DateFormat.yMd(l.localeName).format(publishedAt)),
      if (start != null && end != null) l.playerYears(start, end),
    ].join(_metaSeparator);
    if (description == null &&
        event == null &&
        facts.isEmpty &&
        episode.sources.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: _sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(l.playerAboutTitle),
          if (facts.isNotEmpty || description != null)
            Padding(
              padding: const EdgeInsets.only(top: _metaGap),
              child: Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (facts.isNotEmpty)
                      Text(
                        facts,
                        style: context.text.labelMedium?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                    if (facts.isNotEmpty && description != null)
                      const SizedBox(height: _metaGap),
                    if (description != null)
                      ExpandableDescription(text: description),
                  ],
                ),
              ),
            ),
          if (event != null)
            Padding(
              padding: const EdgeInsets.only(top: _cardGap),
              child: _EventCard(event: event),
            ),
          PlayerSources(sources: episode.sources),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EpisodeEventRef event;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        onTap: () => context.push(AppRoutes.eventFor(event.slug)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _eventRowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.pagePadding,
              vertical: _metaGap,
            ),
            child: Row(
              children: [
                Icon(Icons.history_edu_outlined, color: context.accent),
                const SizedBox(width: AppDesign.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.playerRelatedEvent,
                        style: context.text.labelSmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                      Text(
                        event.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppDesign.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
