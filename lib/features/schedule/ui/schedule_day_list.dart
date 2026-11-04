import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';
import 'package:su_ky_mobile/features/schedule/ui/release_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _headerPadding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  AppDesign.gap,
  AppDesign.pagePadding,
  4,
);

/// Releases grouped under local-date headers ("Thứ Sáu, 6 tháng 11").
class ScheduleDayList extends StatelessWidget {
  const ScheduleDayList({super.key, required this.releases});

  final List<Release> releases;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = _group(releases);
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (_, index) => switch (entries[index]) {
        final DateTime day => Padding(
          padding: _headerPadding,
          child: Text(
            l.scheduleDayHeader(day),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        final Release release => ReleaseTile(release: release),
        _ => const SizedBox.shrink(),
      },
    );
  }

  /// A [DateTime] header before the first release of each local day.
  static List<Object> _group(List<Release> releases) {
    final entries = <Object>[];
    DateTime? current;
    for (final release in releases) {
      final local = release.scheduledAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day != current) {
        entries.add(day);
        current = day;
      }
      entries.add(release);
    }
    return entries;
  }
}
