import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/home/ui/home_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// "All" plus one chip per historical period. A failed or empty period list
/// leaves just "All": the series list below still works.
class PeriodPills extends ConsumerWidget {
  const PeriodPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final selected = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);
    final periods = ref.watch(periodsProvider).value ?? const [];
    Widget pill(String label, String? id) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: selected == id ? AppDesign.white : AppDesign.ink,
          ),
        ),
        selected: selected == id,
        onSelected: (_) => vm.select(id),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          pill(l.homeAllPeriods, null),
          for (final period in periods) pill(period.name, period.id),
        ],
      ),
    );
  }
}
