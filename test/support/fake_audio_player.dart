import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

/// Never touches the platform channel; every call succeeds and does nothing.
class FakeAudioPlayer extends Fake implements AudioPlayer {
  final _state = StreamController<PlayerState>.broadcast();
  final _pos = StreamController<Duration>.broadcast();

  @override
  Stream<PlayerState> get playerStateStream => _state.stream;
  @override
  Stream<Duration> get positionStream => _pos.stream;
  @override
  Duration get position => Duration.zero;
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async => null;
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration? position, {int? index}) async {}
  @override
  Future<void> dispose() async {}
}
