import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/mock/mock_catalog.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class NewEpisodeTile extends ConsumerWidget {
  const NewEpisodeTile({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final title = [l.damTitle, l.meTitle, l.lyTitle][index];
    final subtitle = [l.damSubtitle, l.meSubtitle, l.lySubtitle][index];
    final era = [l.damEra, l.meEra, l.lyEra][index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Surface(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CoverArt(
              path: MockCatalog.thumbnails[index],
              height: 48,
              width: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    era,
                    style: context.text.labelSmall?.copyWith(
                      color: AppDesign.muted,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    title,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            RoundPlay(
              onTap: () {
                ref.read(audioViewModelProvider.notifier).playEpisode(index);
                context.push(AppRoutes.player);
              },
              filled: false,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}
