import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/mock/mock_catalog.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class RelatedEpisodeTile extends ConsumerWidget {
  const RelatedEpisodeTile({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = index == ref.watch(audioViewModelProvider).episode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Surface(
        selected: current,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CoverArt(
              path: index.isEven ? MockCatalog.cover : MockCatalog.secondCover,
              width: 48,
              height: 54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => context.push(AppRoutes.series),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (current)
                      Text(
                        l.listeningBadge,
                        style: context.text.labelSmall?.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      episodeTitle(l, index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(l.bachDang, style: context.text.bodySmall),
                    Text(
                      audioTime(MockCatalog.episodeSeconds[index]),
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RoundPlay(
              onTap: () {
                ref.read(audioViewModelProvider.notifier).playEpisode(index);
                context.push(AppRoutes.player);
              },
            ),
          ],
        ),
      ),
    );
  }
}
