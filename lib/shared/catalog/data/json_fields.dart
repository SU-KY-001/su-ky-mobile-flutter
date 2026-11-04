/// Field-level readers for server JSON.
///
/// Every reader validates the value it returns and throws [FormatException]
/// naming the offending field, so a malformed payload fails at the boundary
/// instead of leaking raw maps into the app. Shared by the catalog parsers.
abstract final class JsonFields {
  static Map<String, Object?> object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('Expected $what to be an object');
  }

  static List<Object?> list(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is List<Object?>) return value;
    throw FormatException('Field "$key" must be a list');
  }

  static String string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Field "$key" must be a non-empty string');
  }

  static String? optString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$key" must be a string');
    }
    return value.isEmpty ? null : value;
  }

  static int integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw FormatException('Field "$key" must be an int');
  }

  static int? optInteger(Map<String, Object?> json, String key) =>
      json[key] == null ? null : integer(json, key);

  static DateTime? optDate(Map<String, Object?> json, String key) {
    final value = optString(json, key);
    if (value == null) return null;
    final date = DateTime.tryParse(value);
    if (date == null) throw FormatException('Field "$key" must be a date');
    return date;
  }
}
