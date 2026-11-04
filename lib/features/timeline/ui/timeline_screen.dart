import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/timeline/ui/timeline_entry.dart';
import 'package:su_ky_mobile/features/timeline/ui/timeline_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/period_pills.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _titleGap = 4.0;
const _titleLetterSpacing = -0.8;
const _pillGap = 18.0;
const _listGap = 20.0;
const _bottomPadding = 40.0;

/// History tab: period pills over a vertical timeline of historical events.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final periodId = ref.watch(timelineViewModelProvider);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Text(
            l.timelineTitle,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: _titleLetterSpacing,
            ),
          ),
          const SizedBox(height: _titleGap),
          Text(
            l.timelineSubtitle,
            style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
          ),
          const SizedBox(height: _pillGap),
          PeriodPills(
            selected: periodId,
            onSelect: (id) =>
                ref.read(timelineViewModelProvider.notifier).select(id),
          ),
          const SizedBox(height: _listGap),
          CatalogAsyncView<List<HistoricalEvent>>(
            value: ref.watch(eventsProvider(periodId)),
            onRetry: () => ref.invalidate(eventsProvider(periodId)),
            isEmpty: (events) => events.isEmpty,
            emptyTitle: l.timelineEmptyTitle,
            emptyMessage: l.timelineEmptyMessage,
            builder: (events) => Column(
              children: [
                for (final (index, event) in events.indexed)
                  TimelineEntry(
                    event: event,
                    first: index == 0,
                    last: index == events.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: _bottomPadding),
        ],
      ),
    );
  }
}
