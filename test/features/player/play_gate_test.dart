import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';

class _FakePlayback extends PlaybackController {
  int plays = 0;
  bool? lastAutoplay;

  @override
  PlaybackState build() => const PlaybackState();

  @override
  Future<PlayOutcome> playEpisode(
    String slug, {
    String? narrationId,
    bool autoplay = true,
  }) async {
    plays++;
    lastAutoplay = autoplay;
    return PlayOutcome.started;
  }
}

class _PlayProbe extends ConsumerWidget {
  const _PlayProbe({this.autoplay = true});

  final bool autoplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => playFromUi(context, ref, 'ep-1', autoplay: autoplay),
        child: const Text('play'),
      ),
    ),
  );
}

Future<(GoRouter, _FakePlayback)> _pump(
  WidgetTester tester, {
  required String initialLocation,
}) async {
  final playback = _FakePlayback();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.podcast,
        builder: (_, _) => const _PlayProbe(autoplay: false),
      ),
      GoRoute(path: AppRoutes.player, builder: (_, _) => const _PlayProbe()),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        signedInProvider.overrideWithValue(true),
        playbackControllerProvider.overrideWith(() => playback),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (router, playback);
}

int _stackSize(GoRouter router) =>
    router.routerDelegate.currentConfiguration.matches.length;

void main() {
  testWidgets('playing from another screen opens the player once', (
    tester,
  ) async {
    final (router, playback) = await _pump(
      tester,
      initialLocation: AppRoutes.podcast,
    );

    await tester.tap(find.text('play'));
    await tester.pumpAndSettle();

    expect(playback.plays, 1);
    expect(playback.lastAutoplay, isFalse);
    expect(_stackSize(router), 2);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.player,
    );
  });

  testWidgets('the up-next card on the player does not push a second player', (
    tester,
  ) async {
    final (router, playback) = await _pump(
      tester,
      initialLocation: AppRoutes.player,
    );

    await tester.tap(find.text('play'));
    await tester.pumpAndSettle();

    expect(playback.plays, 1);
    expect(_stackSize(router), 1);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.player,
    );
  });
}
