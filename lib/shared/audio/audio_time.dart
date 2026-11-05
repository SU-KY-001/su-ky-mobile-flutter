const _secondsPerMinute = 60;
const _secondsDigits = 2;
const _speedDecimals = 2;
const _decimalPoint = '.';
const _zero = '0';

/// Formats [seconds] as `m:ss` for playback and duration labels.
String audioTime(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ _secondsPerMinute;
  final remaining = safe % _secondsPerMinute;
  return '$minutes:${remaining.toString().padLeft(_secondsDigits, _zero)}';
}

/// Formats a playback speed, dropping the last zero of whole tenths
/// (`1.00` -> `1.0`, `1.50` -> `1.5`, `1.25` -> `1.25`).
String audioSpeed(double speed) {
  var text = speed.toStringAsFixed(_speedDecimals);
  final wholeTenth = '$_decimalPoint$_zero';
  while (text.endsWith(_zero) && !text.endsWith(wholeTenth)) {
    text = text.substring(0, text.length - 1);
  }
  return text;
}
