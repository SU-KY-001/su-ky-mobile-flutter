import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/player/ui/player_about.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/links/link_opener.dart';

EpisodeDetail _episode({
  String? description,
  EpisodeEventRef? event,
  List<EpisodeSource> sources = const [],
}) => EpisodeDetail(
  id: 'e',
  slug: 'ep',
  title: 'Ep',
  seriesSlug: 's',
  seriesTitle: 'S',
  hasQuiz: false,
  narrations: const [],
  description: description,
  event: event,
  sources: sources,
);

final _opened = <Uri>[];
String? _openedEvent;

Future<AppLocalizations> _pump(
  WidgetTester tester,
  EpisodeDetail e, {
  bool launchWorks = true,
}) async {
  _openedEvent = null;
  _opened.clear();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(child: PlayerAbout(episode: e)),
        ),
      ),
      GoRoute(
        path: '/events/:slug',
        builder: (_, state) {
          _openedEvent = state.pathParameters['slug'];
          return const Scaffold();
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        linkOpenerProvider.overrideWithValue((uri) async {
          _opened.add(uri);
          return launchWorks;
        }),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(Scaffold)));
}

const _full = EpisodeDetail(
  id: 'e',
  slug: 'ep',
  title: 'Ep',
  seriesSlug: 's',
  seriesTitle: 'S',
  hasQuiz: false,
  narrations: [],
  description: 'Mô tả tập',
  event: EpisodeEventRef(slug: 'ev-1', name: 'Sự kiện X'),
  sources: [
    EpisodeSource(title: 'Nguồn A', publisher: 'NXB', url: 'https://a.vn'),
    EpisodeSource(title: 'Nguồn B'),
  ],
);

void main() {
  testWidgets('an episode with no extra data renders nothing', (tester) async {
    final l = await _pump(tester, _episode());
    expect(find.text(l.playerAboutTitle), findsNothing);
  });

  testWidgets('shows description, event and sources; the event opens its '
      'page', (tester) async {
    final l = await _pump(tester, _full);
    expect(find.text(l.playerAboutTitle), findsOneWidget);
    expect(find.text('Mô tả tập'), findsOneWidget);
    expect(find.text(l.playerSourcesTitle), findsOneWidget);

    await tester.tap(find.text('Sự kiện X'));
    await tester.pumpAndSettle();
    expect(_openedEvent, 'ev-1');
  });

  testWidgets('a source with a link opens it; one without does nothing', (
    tester,
  ) async {
    await _pump(tester, _full);
    await tester.tap(find.text('Nguồn A'));
    await tester.pump();
    expect(_opened.single, Uri.parse('https://a.vn'));

    await tester.tap(find.text('Nguồn B'));
    await tester.pump();
    expect(_opened, hasLength(1));
  });

  testWidgets('when the browser cannot open the link, the user is told', (
    tester,
  ) async {
    final l = await _pump(tester, _full, launchWorks: false);
    await tester.tap(find.text('Nguồn A'));
    await tester.pump();
    expect(find.text(l.playerSourceOpenFailed), findsOneWidget);
  });
}
