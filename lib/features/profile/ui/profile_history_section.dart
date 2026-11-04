import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/profile/ui/history_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/history/history_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';

/// The five most recent episodes plus a link to the full history.
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
      builder: (data) {
        final items = data?.items ?? const <HistoryEntry>[];
        final preview = items.take(recentHistoryLimit);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in preview) HistoryTile(entry: entry),
            if (items.length >= recentHistoryLimit)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.listeningHistory),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, AppDesign.tapTarget),
                  ),
                  child: Text(l.viewAll),
                ),
              ),
          ],
        );
      },
    );
  }
}
