import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/timeline/timeline_period.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _rowHeight = 56.0;
const _rowGap = 8.0;
const _nameMaxLines = 2;

/// One tile per period, stacked; a tile opens the Timeline tab with that
/// period selected. Hidden while the list loads, fails or is empty.
class HomePeriodsSection extends ConsumerWidget {
  const HomePeriodsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periods = ref.watch(periodsProvider).value;
    if (periods == null || periods.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(AppLocalizations.of(context).homePeriodsTitle),
        for (final period in periods)
          _PeriodTile(
            period: period,
            onTap: () {
              ref.read(timelineViewModelProvider.notifier).select(period.id);
              context.go(AppRoutes.history);
            },
          ),
      ],
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period, required this.onTap});

  final HistoricalPeriod period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: _rowGap),
    child: Material(
      color: AppDesign.tint,
      borderRadius: BorderRadius.circular(AppDesign.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _rowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.gap,
              vertical: _rowGap,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    period.name,
                    maxLines: _nameMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppDesign.muted),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
