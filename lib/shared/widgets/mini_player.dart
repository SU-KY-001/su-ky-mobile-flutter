import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_defaults.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioViewModelProvider);
    final controller = ref.read(audioViewModelProvider.notifier);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Surface(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: state.progress,
              minHeight: 2,
              color: context.accent,
              backgroundColor: AppDesign.line,
            ),
            ListTile(
              dense: true,
              onTap: onOpen,
              leading: Icon(Icons.menu_book_outlined, color: context.accent),
              title: Text(
                l.playerTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(l.ngoDynasty),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.seekBack,
                    onPressed: () =>
                        controller.skip(-AudioDefaults.seekStepSeconds),
                    icon: const Icon(Icons.replay),
                  ),
                  RoundPlay(
                    onTap: controller.toggle,
                    playing: state.playing,
                    size: 36,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
