import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/providers.dart';
import '../../core/logging/app_logger.dart';

const _positionKeyPrefix = 'playback.pos.';
const _lastEpisodeKey = 'playback.lastEpisode';

/// The episode the user listened to last.
final class LastListen {
  const LastListen({required this.slug, required this.narrationId});

  final String slug;
  final String narrationId;
}

/// Device-local playback memory: resume position per narration (seconds) and
/// the last episode. Not synced; server sync is a separate concern.
class LocalPlaybackStore {
  LocalPlaybackStore(this._prefs);

  final SharedPreferences _prefs;

  int position(String narrationId) =>
      _prefs.getInt('$_positionKeyPrefix$narrationId') ?? 0;

  Future<void> savePosition(String narrationId, int seconds) => _write(
    'Cannot save playback position',
    () => _prefs.setInt('$_positionKeyPrefix$narrationId', seconds),
  );

  LastListen? lastEpisode() {
    final raw = _prefs.getString(_lastEpisodeKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, Object?>) {
        final slug = json['slug'], narrationId = json['narrationId'];
        if (slug is String &&
            slug.isNotEmpty &&
            narrationId is String &&
            narrationId.isNotEmpty) {
          return LastListen(slug: slug, narrationId: narrationId);
        }
      }
    } on FormatException catch (error, stackTrace) {
      AppLogger.error(
        'Cannot read last episode',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<void> saveLastEpisode(LastListen last) => _write(
    'Cannot save last episode',
    () => _prefs.setString(
      _lastEpisodeKey,
      jsonEncode({'slug': last.slug, 'narrationId': last.narrationId}),
    ),
  );

  Future<void> clearLastEpisode() =>
      _write('Cannot clear last episode', () => _prefs.remove(_lastEpisodeKey));

  Future<void> _write(String what, Future<bool> Function() write) async {
    try {
      await write();
    } on Object catch (error, stackTrace) {
      AppLogger.error(what, error: error, stackTrace: stackTrace);
    }
  }
}

final localPlaybackStoreProvider = Provider<LocalPlaybackStore>(
  (ref) => LocalPlaybackStore(ref.watch(sharedPreferencesProvider)),
);
