import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class ContinueListeningCard extends ConsumerWidget {
  const ContinueListeningCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final audio = ref.watch(audioViewModelProvider);
    final vm = ref.read(audioViewModelProvider.notifier);
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.continueListening,
                style: context.text.labelSmall?.copyWith(
                  color: context.accent,
                  letterSpacing: .8,
                ),
              ),
              const Spacer(),
              Text(
                '${audioTime(audio.position)} / ${audioTime(audio.duration)}',
                style: context.text.labelSmall?.copyWith(
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.push(AppRoutes.player),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.resumeTitle,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.resumeSubtitle,
                        style: context.text.bodySmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RoundPlay(
                onTap: () {
                  vm.playEpisode(audio.episode);
                  context.push(AppRoutes.player);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: audio.progress,
              minHeight: 4,
              color: context.accent,
              backgroundColor: AppDesign.line,
            ),
          ),
        ],
      ),
    );
  }
}
