import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/widgets/login_required_dialog.dart';

/// The one Play action of the UI. A guest is asked to sign in (the request is
/// replayed after login, or dropped if they decline). Everyone else lands on
/// the player at once, which shows loading, then audio or a retryable error.
Future<void> playFromUi(
  BuildContext context,
  WidgetRef ref,
  String slug, {
  String? narrationId,
}) async {
  final controller = ref.read(playbackControllerProvider.notifier);
  if (ref.read(signedInProvider)) {
    unawaited(controller.playEpisode(slug, narrationId: narrationId));
    unawaited(context.push(AppRoutes.player));
    return;
  }
  await controller.playEpisode(slug, narrationId: narrationId);
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
  unawaited(context.push(AppRoutes.login));
}
