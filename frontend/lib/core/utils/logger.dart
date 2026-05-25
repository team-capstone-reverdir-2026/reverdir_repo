import 'package:flutter/foundation.dart';

/// Reverdir 디버그 로그 — 릴리스 빌드에서는 출력하지 않음.
class AppLogger {
  AppLogger._();

  static const String _prefix = '[Reverdir DEBUG]';

  static void d(String message, [Object? detail]) {
    if (!kDebugMode) return;
    final buffer = StringBuffer('$_prefix $message');
    if (detail != null) buffer.write(' | $detail');
    debugPrint(buffer.toString());
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    if (!kDebugMode) return;
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) debugPrint('$_prefix   cause: $error');
    if (stack != null) debugPrint('$_prefix   $stack');
  }

  /// API 요청·응답 추적용
  static void network(String method, String path, {int? status}) {
    d('HTTP $method $path', status != null ? 'status=$status' : null);
  }
}
