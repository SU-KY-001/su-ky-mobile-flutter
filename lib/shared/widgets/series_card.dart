import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class SeriesCard extends StatelessWidget {
  const SeriesCard({
    super.key,
    required this.onTap,
    this.secondary = false,
    this.large = false,
  });
  final VoidCallback onTap;
  final bool secondary;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Surface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CoverArt(
                  path: secondary ? AppDesign.secondCover : AppDesign.cover,
                  height: large ? 155 : 126,
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      secondary ? l.eightEpisodes : l.sixEpisodes,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (large)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l.resistanceTag,
                        style: context.text.labelSmall?.copyWith(
                          color: context.accent,
                          letterSpacing: .6,
                        ),
                      ),
                    ),
                  Text(
                    secondary
                        ? l.secondSeries
                        : (large ? l.seriesShort : l.seriesTitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (large
                                ? context.text.titleMedium
                                : context.text.labelLarge)
                            ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    large
                        ? l.searchDescription
                        : (secondary ? l.secondAuthor : l.author),
                    maxLines: large ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          secondary ? l.tranDynasty : l.warHistory,
                          style: context.text.labelSmall?.copyWith(
                            color: AppDesign.muted,
                          ),
                        ),
                      ),
                      if (large)
                        Text(l.detail, style: TextStyle(color: context.accent))
                      else ...[
                        Icon(Icons.star, size: 12, color: context.accent),
                        Text(
                          l.rating,
                          style: context.text.labelSmall?.copyWith(
                            color: context.accent,
                          ),
                        ),
                      ],
                    ],
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
