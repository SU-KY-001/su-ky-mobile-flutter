import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// "All" plus one chip per historical period. A failed or empty period list
/// leaves just "All": the list below still works.
///
/// Used by the Timeline tab; its selection lives in `timelineViewModelProvider`.
class PeriodPills extends ConsumerWidget {
  const PeriodPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// Id of the selected period, or null for "all periods".
  final String? selected;

  /// Called with the new period id, or null for "all periods".
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
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
        onSelected: (_) => onSelect(id),
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
