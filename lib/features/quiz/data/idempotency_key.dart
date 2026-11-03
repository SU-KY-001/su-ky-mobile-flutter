import 'dart:math';

const _uuidByteLength = 16;
const _uuidVersionIndex = 6;
const _uuidVariantIndex = 8;
const _uuidVersionMask = 0x0f;
const _uuidVersion4 = 0x40;
const _uuidVariantMask = 0x3f;
const _uuidVariantRfc4122 = 0x80;
const _byteMax = 0xff;
const _hexRadix = 16;
const _hexPairWidth = 2;
const _dashAfterIndexes = {4, 6, 8, 10};

final _secureRandom = Random.secure();

/// Random RFC 4122 version-4 UUID, accepted by the API's `Idempotency-Key`.
/// A two-line package is not worth a new dependency.
String newIdempotencyKey() {
  final bytes = List<int>.generate(
    _uuidByteLength,
    (_) => _secureRandom.nextInt(_byteMax + 1),
  );
  bytes[_uuidVersionIndex] =
      (bytes[_uuidVersionIndex] & _uuidVersionMask) | _uuidVersion4;
  bytes[_uuidVariantIndex] =
      (bytes[_uuidVariantIndex] & _uuidVariantMask) | _uuidVariantRfc4122;

  final hex = StringBuffer();
  for (var index = 0; index < bytes.length; index++) {
    if (_dashAfterIndexes.contains(index)) hex.write('-');
    hex.write(
      bytes[index].toRadixString(_hexRadix).padLeft(_hexPairWidth, '0'),
    );
  }
  return hex.toString();
}
