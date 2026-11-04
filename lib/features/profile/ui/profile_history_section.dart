import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/profile/ui/history_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/history/history_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';

/// Flat "recently played" rows under the recent section label.
class ProfileHistorySection extends ConsumerWidget {
  const ProfileHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(listeningHistoryProvider);
    return CatalogAsyncView<ListeningHistory?>(
      value: history,
      onRetry: () => ref.invalidate(listeningHistoryProvider),
      isEmpty: (data) => data == null || data.items.isEmpty,
      emptyMessage: l.profileRecentEmpty,
      builder: (data) => Column(
        children: [
          for (final entry in data?.items ?? const <HistoryEntry>[])
            HistoryTile(entry: entry),
        ],
      ),
    );
  }
}
