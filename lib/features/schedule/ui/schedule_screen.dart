import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/schedule/data/schedule_providers.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';
import 'package:su_ky_mobile/features/schedule/ui/schedule_day_list.dart';
import 'package:su_ky_mobile/features/schedule/ui/schedule_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _dividerHeight = 1.0;
const _switcherPadding = EdgeInsets.symmetric(
  horizontal: AppDesign.gap,
  vertical: 4,
);

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final month = ref.watch(scheduleViewModelProvider);
    final releases = ref.watch(scheduleProvider(month));
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo(AppRoutes.profile),
          tooltip: l.back,
          icon: const Icon(Symbols.chevron_left),
        ),
        title: Text(l.scheduleTitle),
      ),
      child: Column(
        children: [
          _MonthSwitcher(month: month),
          const Divider(height: _dividerHeight),
          Expanded(
            child: CatalogAsyncView<List<Release>>(
              value: releases,
              onRetry: () => ref.invalidate(scheduleProvider(month)),
              isEmpty: (items) => items.isEmpty,
              emptyMessage: l.scheduleEmpty,
              builder: (items) => ScheduleDayList(releases: items),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  const _MonthSwitcher({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final model = ref.read(scheduleViewModelProvider.notifier);
    return Padding(
      padding: _switcherPadding,
      child: Row(
        children: [
          IconButton(
            onPressed: model.previous,
            tooltip: l.schedulePrevMonth,
            icon: const Icon(Symbols.chevron_left),
          ),
          Expanded(
            child: Text(
              l.scheduleMonth(month),
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: model.next,
            tooltip: l.scheduleNextMonth,
            icon: const Icon(Symbols.chevron_right),
          ),
        ],
      ),
    );
  }
}
