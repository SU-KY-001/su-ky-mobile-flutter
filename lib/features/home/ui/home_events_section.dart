import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _maxEvents = 3;
const _rowGap = 8.0;
const _titleMaxLines = 2;
const _summaryMaxLines = 2;
const _textGap = 4.0;

/// The first few events; "View all" opens the Timeline tab.
class HomeEventsSection extends ConsumerWidget {
  const HomeEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          l.homeEventsTitle,
          action: l.viewAll,
          onTap: () => context.go(AppRoutes.history),
        ),
        CatalogAsyncView(
          value: ref.watch(eventsProvider(null)),
          onRetry: () => ref.invalidate(eventsProvider(null)),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: l.homeEventsEmpty,
          builder: (items) => Column(
            children: [
              for (final event in items.take(_maxEvents)) _EventCard(event),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard(this.event);

  final HistoricalEvent event;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: _rowGap),
    child: Material(
      color: AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        side: const BorderSide(color: AppDesign.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.eventFor(event.slug)),
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.timeLabel,
                style: context.text.labelMedium?.copyWith(
                  color: context.accent,
                ),
              ),
              const SizedBox(height: _textGap),
              Text(
                event.name,
                maxLines: _titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: _textGap),
              Text(
                event.summary,
                maxLines: _summaryMaxLines,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
