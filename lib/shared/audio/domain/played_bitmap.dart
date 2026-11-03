import 'dart:convert';
import 'dart:typed_data';

const _bitsPerByte = 8;
const _millisPerSecond = 1000;

/// One played bit per second of audio, LSB first, as the progress API expects.
final class PlayedBitmap {
  PlayedBitmap(int durationMs)
    : totalSeconds = _secondsFor(durationMs),
      _bits = Uint8List(_bytesFor(durationMs));

  final int totalSeconds;
  final Uint8List _bits;

  static int _secondsFor(int durationMs) =>
      (durationMs / _millisPerSecond).ceil();

  static int _bytesFor(int durationMs) =>
      (_secondsFor(durationMs) / _bitsPerByte).ceil();

  void mark(int second) {
    if (second < 0 || second >= totalSeconds) return;
    _bits[second ~/ _bitsPerByte] |= 1 << (second % _bitsPerByte);
  }

  bool get isEmpty => !_bits.any((byte) => byte != 0);

  String toBase64() => base64Encode(_bits);

  void clear() => _bits.fillRange(0, _bits.length, 0);
}
