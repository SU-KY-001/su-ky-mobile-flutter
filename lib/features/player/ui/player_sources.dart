import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/links/link_opener.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _topGap = 24.0;
const _headingGap = 8.0;
const _rowHeight = 56.0;
const _rowVerticalPadding = 8.0;
const _titleMaxLines = 2;

/// Cited sources of the series. A row with a link opens it in the phone's
/// default browser; hidden when there are no sources.
class PlayerSources extends StatelessWidget {
  const PlayerSources({super.key, required this.sources});

  final List<EpisodeSource> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: _topGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(l.playerSourcesTitle),
          const SizedBox(height: _headingGap),
          Surface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < sources.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _SourceRow(source: sources[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends ConsumerWidget {
  const _SourceRow({required this.source});

  final EpisodeSource source;

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).playerSourceOpenFailed;
    final opened = await ref.read(linkOpenerProvider)(Uri.parse(url));
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final url = source.url;
    final publisher = source.publisher;
    return InkWell(
      onTap: url == null ? null : () => _open(context, ref, url),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.pagePadding,
            vertical: _rowVerticalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.title,
                      maxLines: _titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (publisher != null)
                      Text(
                        publisher,
                        style: context.text.bodySmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (url != null)
                Tooltip(
                  message: l.playerSourceOpen,
                  child: const Icon(Icons.open_in_new, color: AppDesign.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
