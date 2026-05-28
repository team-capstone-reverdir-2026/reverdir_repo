import 'dart:developer' as developer;

/// API 실패 추적 및 사용자 표시 메시지 생성 유틸.
class ApiErrorTracker {
  ApiErrorTracker._();

  static String logAndBuildMessage({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final message = '[API 에러] $method $url 연결 실패 - 서버 상태를 확인하세요.';
    developer.log(
      message,
      name: 'ReverdirApi',
      error: error,
      stackTrace: stackTrace,
    );
    return message;
  }
}
