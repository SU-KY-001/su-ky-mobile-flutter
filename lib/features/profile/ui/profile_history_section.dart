import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/profile/ui/history_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/history/history_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class ProfileHistorySection extends ConsumerWidget {
  const ProfileHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(listeningHistoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(l.profileRecentTitle),
        CatalogAsyncView<ListeningHistory?>(
          value: history,
          onRetry: () => ref.invalidate(listeningHistoryProvider),
          isEmpty: (data) => data == null || data.items.isEmpty,
          emptyMessage: l.profileRecentEmpty,
          builder: (data) {
            final entries = data?.items ?? const <HistoryEntry>[];
            return Column(
              children: [
                for (final (index, entry) in entries.indexed) ...[
                  if (index > 0) const SizedBox(height: AppDesign.gap),
                  HistoryTile(entry: entry),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
