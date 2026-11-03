import 'dart:async';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/logging/app_logger.dart';
import 'audio_defaults.dart';
import 'data/playback_repository.dart';
import 'domain/playback_info.dart';
import 'domain/played_bitmap.dart';
import 'domain/progress_update.dart';

const _audioChangedCode = 'AUDIO_CHANGED';
const _progressInvalidCode = 'PROGRESS_INVALID';

/// Collects played seconds of the current narration and sends them to the
/// server on a timer, on pause and when playback ends.
class ProgressSync {
  ProgressSync({
    required this.repository,
    required this.isSignedIn,
    required this.onCompleted,
  });

  final PlaybackRepository repository;
  final bool Function() isSignedIn;
  final void Function(ListeningCompletion) onCompleted;

  PlaybackInfo? _info;
  PlayedBitmap? _bitmap;
  Timer? _timer;
  Duration? _previous;
  Duration _lastPosition = Duration.zero;
  int _generation = 0;
  bool _dirty = false;
  bool _saving = false;
  Future<void>? _inFlight;
  bool _disabled = false;

  void begin(PlaybackInfo info) {
    _timer?.cancel();
    _generation++;
    _info = info;
    _bitmap = PlayedBitmap(info.durationMs);
    _previous = null;
    _lastPosition = Duration.zero;
    _dirty = false;
    _saving = false;
    _disabled = false;
    _timer = Timer.periodic(info.syncInterval, (_) => unawaited(flush()));
  }

  /// Re-arms the timer after a completed episode is played again from zero.
  void rearm() {
    final info = _info;
    if (info == null) return;
    final disabled = _disabled;
    begin(info);
    _disabled = disabled;
  }

  void onPosition(Duration position, {required bool playing}) {
    _lastPosition = position;
    if (!playing || !isSignedIn()) {
      _previous = position;
      return;
    }
    final previous = _previous;
    _previous = position;
    if (previous == null) return;
    final delta = position - previous;
    if (delta <= Duration.zero ||
        delta > const Duration(seconds: AudioDefaults.maxTickDeltaSeconds)) {
      return;
    }
    final bitmap = _bitmap;
    if (bitmap == null) return;
    for (
      var second = previous.inSeconds;
      second < position.inSeconds;
      second++
    ) {
      bitmap.mark(second);
    }
    _dirty = true;
  }

  /// A seek breaks the position chain: jumped-over seconds are not marked.
  void onSeek() => _previous = null;

  Future<void> flush({bool force = false}) {
    if (_disabled || _saving || (!force && !_dirty) || !isSignedIn()) {
      return Future<void>.value();
    }
    final send = _send();
    _inFlight = send;
    return send;
  }

  Future<void> _send() async {
    final info = _info;
    final bitmap = _bitmap;
    if (info == null || bitmap == null) return;
    final generation = _generation;
    _saving = true;
    try {
      final result = await repository.updateProgress(
        narrationId: info.narrationId,
        assetId: info.assetId,
        positionMs: _lastPosition.inMilliseconds.clamp(0, info.durationMs),
        playedBitmap: bitmap.toBase64(),
      );
      if (generation != _generation) return;
      switch (result) {
        case Ok(:final value):
          _dirty = false;
          final completion = value.completion;
          if (completion != null) onCompleted(completion);
        case Err(:final error):
          _handleError(error);
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Progress sync failed unexpectedly',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (generation == _generation) _saving = false;
    }
  }

  /// Waits for a send already in flight so the final position is not dropped.
  Future<void> end() async {
    await _inFlight;
    await flush();
    _generation++;
    _timer?.cancel();
    _timer = null;
    _previous = null;
  }

  void _handleError(AppException error) {
    final code = error is ApiException ? error.errorCode : null;
    if (code == _audioChangedCode) {
      _disabled = true;
      _timer?.cancel();
      _timer = null;
      AppLogger.error(
        'Progress disabled: audio changed on the server',
        error: error,
        stackTrace: StackTrace.current,
      );
      return;
    }
    if (code == _progressInvalidCode) {
      _bitmap?.clear();
      _dirty = false;
      AppLogger.error(
        'Progress rejected: played bitmap cleared',
        error: error,
        stackTrace: StackTrace.current,
      );
      return;
    }
    AppLogger.error(
      'Progress sync failed; will retry on the next tick',
      error: error,
      stackTrace: StackTrace.current,
    );
  }
}
