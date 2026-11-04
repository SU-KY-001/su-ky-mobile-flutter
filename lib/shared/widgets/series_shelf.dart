import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/shelf_card.dart';

/// Two title lines + one subtitle line under the 150 cover, scaled with text size.
const _shelfTextHeight = 76.0;
const _cardGap = 12.0;

/// Horizontal Spotify-style shelf of [ShelfCard]s opening the series detail.
class SeriesShelf extends StatelessWidget {
  const SeriesShelf({super.key, required this.series});

  final List<SeriesSummary> series;

  @override
  Widget build(BuildContext context) => SizedBox(
    height:
        shelfCoverSize +
        MediaQuery.textScalerOf(context).scale(_shelfTextHeight),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: series.length,
      separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
      itemBuilder: (_, index) => ShelfCard(
        series: series[index],
        onTap: () => context.push(AppRoutes.seriesFor(series[index].slug)),
      ),
    ),
  );
}
