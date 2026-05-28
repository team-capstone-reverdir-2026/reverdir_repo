import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'auth_interceptor.dart';

/// Dio 단일 인스턴스 팩토리.
///
/// 초기화 흐름:
/// [DioClient.instance.init] → Base URL·타임아웃 → [AuthInterceptor] 등록
/// → [apiClient] getter로 [ApiClient] 노출
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  static const Duration _timeout = Duration(seconds: 10);

  Dio? _dio;
  AuthTokenProvider? _tokenProvider;

  /// 초기화 여부
  bool get isInitialized => _dio != null;

  Dio get dio {
    final value = _dio;
    if (value == null) {
      throw StateError(
        'DioClient is not initialized. Call DioClient.instance.init() first.',
      );
    }
    return value;
  }

  /// [init] 후 Feature는 [ApiClient]만 사용 (Dio 직접 접근 금지).
  void init({
    String baseUrl = ApiEndpoints.baseUrl,
    AuthTokenProvider? tokenProvider,
    void Function()? onTokenInvalidated,
  }) {
    _tokenProvider = tokenProvider ?? InMemoryAuthTokenProvider();

    final client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    client.interceptors.add(
      AuthInterceptor(
        dio: client,
        tokenProvider: _tokenProvider!,
        onTokenInvalidated: onTokenInvalidated,
      ),
    );

    _dio = client;
  }

  /// 테스트·환경 전환용 Base URL 변경 (init 이후)
  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }
}
