/// Bundled artwork used when the server has no image for an item (all real
/// series have `cover: null` today).
const _fallbackAssets = [
  'assets/images/bach_dang.jpg',
  'assets/images/dong_a.jpg',
  'assets/images/dam_da.jpg',
  'assets/images/me_linh.jpg',
  'assets/images/thang_long.jpg',
];

/// Picks an asset deterministically from [seed]. Not `String.hashCode`: that
/// differs between runs, and the same series must keep the same picture.
String fallbackArtFor(String seed) {
  final sum = seed.codeUnits.fold<int>(0, (total, unit) => total + unit);
  return _fallbackAssets[sum % _fallbackAssets.length];
}
