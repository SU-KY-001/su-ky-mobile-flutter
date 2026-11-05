import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/widgets/login_required_dialog.dart';

/// The one entry point from the UI to the player. A guest is asked to sign in
/// (the request is replayed after login, or dropped if they decline).
/// Everyone else lands on the player at once, which shows loading, then audio
/// or a retryable error. Audio starts only when [autoplay] is true; opening
/// an episode from a row passes false so the user must press Play.
Future<void> playFromUi(
  BuildContext context,
  WidgetRef ref,
  String slug, {
  String? narrationId,
  bool autoplay = true,
}) async {
  final controller = ref.read(playbackControllerProvider.notifier);
  final route = GoRouterState.of(context);
  if (ref.read(signedInProvider)) {
    unawaited(
      controller.playEpisode(
        slug,
        narrationId: narrationId,
        autoplay: autoplay,
      ),
    );
    // The player's own "up next" card must not stack a second player page.
    if (route.matchedLocation != AppRoutes.player) {
      unawaited(context.push(AppRoutes.player));
    }
    return;
  }
  await controller.playEpisode(
    slug,
    narrationId: narrationId,
    autoplay: autoplay,
  );
  if (!context.mounted) return;
  final signIn = await showDialog<bool>(
    context: context,
    builder: (_) => const LoginRequiredDialog(),
  );
  if (signIn != true) {
    controller.cancelPendingPlay();
    return;
  }
  if (!context.mounted) return;
  unawaited(context.push(AppRoutes.loginFor(route.uri.toString())));
}
