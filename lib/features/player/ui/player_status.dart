import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _gap = 12.0;
const _spinnerSize = 32.0;

/// Loading, error (with retry) and the empty "no episode" state.
class PlayerStatusView extends ConsumerWidget {
  const PlayerStatusView({super.key, required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return switch (state.status) {
      PlaybackStatus.loading => _StatusBody(
        message: l.playerLoading,
        leading: const SizedBox.square(
          dimension: _spinnerSize,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      PlaybackStatus.error => _StatusBody(
        message: _errorMessage(l, state.error),
        action: _RetryButton(state: state),
      ),
      PlaybackStatus.idle || PlaybackStatus.ready => _StatusBody(
        message: l.playerEmpty,
        action: FilledButton(
          onPressed: () => context.go(AppRoutes.podcast),
          child: Text(l.playerEmptyAction),
        ),
      ),
    };
  }

  String _errorMessage(AppLocalizations l, PlaybackError? error) =>
      switch (error) {
        PlaybackError.unavailable => l.playerUnavailable,
        PlaybackError.network => l.playerNetworkError,
        PlaybackError.player => l.playerPlaybackError,
        null => l.playerEmpty,
      };
}

class _RetryButton extends ConsumerWidget {
  const _RetryButton({required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = state.request;
    if (request == null) return const SizedBox.shrink();
    return FilledButton(
      onPressed: () => unawaited(
        ref
            .read(playbackControllerProvider.notifier)
            .playEpisode(request.slug, narrationId: request.narrationId),
      ),
      child: Text(AppLocalizations.of(context).playerRetry),
    );
  }
}

class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.message, this.leading, this.action});

  final String message;
  final Widget? leading;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDesign.gap),
    child: Column(
      children: [
        if (leading != null) ...[leading!, const SizedBox(height: _gap)],
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
        ),
        if (action != null) ...[const SizedBox(height: _gap), action!],
      ],
    ),
  );
}
