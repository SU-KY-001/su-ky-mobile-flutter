import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/logging/app_logger.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _cardGap = 12.0;
const _sectionGap = 12.0;

/// Series linked to [eventId]. Loading shows nothing so the rest of the page
/// is never blocked; a failed or empty request hides the whole section.
class EventRelatedSeries extends ConsumerWidget {
  const EventRelatedSeries({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ref
        .watch(eventSeriesProvider(eventId))
        .when(
          loading: () => const SizedBox.shrink(),
          error: (error, stack) {
            AppLogger.error(
              'Related series: section hidden',
              error: error,
              stackTrace: stack,
            );
            return const SizedBox.shrink();
          },
          data: (series) => series.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: _sectionGap),
                    SectionHeading(l.eventRelatedTitle),
                    for (final item in series)
                      Padding(
                        padding: const EdgeInsets.only(bottom: _cardGap),
                        child: SeriesCard(
                          series: item,
                          onTap: () =>
                              context.push(AppRoutes.seriesFor(item.slug)),
                        ),
                      ),
                  ],
                ),
        );
  }
}
