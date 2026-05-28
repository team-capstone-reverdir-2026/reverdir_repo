import 'dart:developer' as developer;

import 'error_handler.dart';

/// API 실패 추적 및 사용자 표시 메시지 생성 유틸.
class ApiErrorTracker {
  ApiErrorTracker._();

  /// 서버·개발자용 로그만 남기고, 화면에는 [userMessage]만 씁니다.
  static String logAndBuildMessage({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[API 에러] $method $url',
      name: 'ReverdirApi',
      error: error,
      stackTrace: stackTrace,
    );
    return userMessage(error);
  }

  static String userMessage(Object error) {
    if (error is ApiException) {
      final trimmed = error.message.trim();
      if (trimmed.isNotEmpty) return trimmed;
      return error.code.displayLabel;
    }
    return '요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.';
  }
}
