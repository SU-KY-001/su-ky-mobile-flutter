import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/profile/ui/history_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/history/history_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _padding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  8,
  AppDesign.pagePadding,
  32,
);

/// Full listening history, newest first.
class ListeningHistoryScreen extends ConsumerWidget {
  const ListeningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(fullListeningHistoryProvider);
    return AppPage(
      appBar: AppBar(title: Text(l.profileRecentTitle)),
      child: ListView(
        padding: _padding,
        children: [
          CatalogAsyncView<ListeningHistory?>(
            value: history,
            onRetry: () => ref.invalidate(fullListeningHistoryProvider),
            isEmpty: (data) => data == null || data.items.isEmpty,
            emptyMessage: l.profileRecentEmpty,
            builder: (data) => Column(
              children: [
                for (final entry in data?.items ?? const <HistoryEntry>[])
                  HistoryTile(entry: entry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
