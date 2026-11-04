import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/timeline/ui/event_citations.dart';
import 'package:su_ky_mobile/features/timeline/ui/event_header.dart';
import 'package:su_ky_mobile/features/timeline/ui/event_related_series.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _sectionGap = 24.0;
const _bottomPadding = 40.0;

/// Full historical event: header, cited sources and linked series.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo(AppRoutes.history),
          tooltip: l.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text(l.eventDetailTitle),
      ),
      child: ref
          .watch(eventDetailProvider(slug))
          .when(
            loading: () => const CatalogLoading(),
            error: (error, _) => CatalogError(
              error: error,
              onRetry: () => ref.invalidate(eventDetailProvider(slug)),
            ),
            data: (event) => ListView(
              padding: const EdgeInsets.all(AppDesign.pagePadding),
              children: [
                EventHeader(event: event),
                const SizedBox(height: _sectionGap),
                EventCitations(citations: event.citations),
                EventRelatedSeries(eventId: event.id),
                const SizedBox(height: _bottomPadding),
              ],
            ),
          ),
    );
  }
}
