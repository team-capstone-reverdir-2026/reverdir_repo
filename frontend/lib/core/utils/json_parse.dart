/// API JSON 안전 파싱 — Flutter Web 릴리스에서 `as int`/`as bool` 실패 방지.
library;

int parseJsonInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool parseJsonBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  if (value is num) return value != 0;
  return fallback;
}

String parseJsonString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

Map<String, dynamic>? parseJsonMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> parseJsonMapList(dynamic value) {
  if (value is! List) return const [];
  final out = <Map<String, dynamic>>[];
  for (final item in value) {
    final map = parseJsonMap(item);
    if (map != null) out.add(map);
  }
  return out;
}
