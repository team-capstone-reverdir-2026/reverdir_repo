import 'package:dio/dio.dart';

import 'api_enums.dart';

/// doc/api-docs.json ErrorResponse 바인딩.
class ErrorResponse {
  const ErrorResponse({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  ErrorCode get errorCode => ErrorCode.tryParse(code);
}

/// Feature/UI로 전달되는 가공 예외.
///
/// [ErrorHandler.fromDioException] → [ApiClient] try-catch 경로로만 생성됩니다.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.raw,
  });

  final ErrorCode code;
  final String message;
  final int? statusCode;
  final Object? raw;

  @override
  String toString() => 'ApiException($code, $message, status=$statusCode)';
}

/// DioException → ErrorResponse 파싱 → [ApiException] 변환.
class ErrorHandler {
  ErrorHandler._();

  static ApiException fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final body = exception.response?.data;

    if (body is Map<String, dynamic>) {
      final error = ErrorResponse.fromJson(body);
      return ApiException(
        code: error.errorCode,
        message: _resolveMessage(error),
        statusCode: statusCode,
        raw: exception,
      );
    }

    return ApiException(
      code: _codeFromStatus(statusCode),
      message: _networkFallbackMessage(exception),
      statusCode: statusCode,
      raw: exception,
    );
  }

  static String _resolveMessage(ErrorResponse error) {
    final trimmed = error.message.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return error.errorCode.displayLabel;
  }

  static ErrorCode _codeFromStatus(int? statusCode) {
    return switch (statusCode) {
      401 => ErrorCode.unauthorized,
      403 => ErrorCode.forbidden,
      404 => ErrorCode.notFound,
      400 => ErrorCode.validationError,
      _ => ErrorCode.unknown,
    };
  }

  static String _networkFallbackMessage(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        '요청 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요.',
      DioExceptionType.connectionError =>
        '네트워크에 연결할 수 없습니다. 연결 상태를 확인해 주세요.',
      DioExceptionType.cancel => '요청이 취소되었습니다.',
      _ => '알 수 없는 오류가 발생했습니다.',
    };
  }
}
