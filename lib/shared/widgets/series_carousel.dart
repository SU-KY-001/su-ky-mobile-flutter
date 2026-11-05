import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';

const _carouselHeight = 264.0;
const _cardWidth = 224.0;
const _cardGap = 16.0;

/// Horizontal list of series cards that open the series detail.
class SeriesCarousel extends StatelessWidget {
  const SeriesCarousel({super.key, required this.series});

  final List<SeriesSummary> series;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _carouselHeight,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: series.length,
      separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
      itemBuilder: (_, index) => SizedBox(
        width: _cardWidth,
        child: SeriesCard(
          series: series[index],
          onTap: () => context.push(AppRoutes.seriesFor(series[index].slug)),
        ),
      ),
    ),
  );
}
