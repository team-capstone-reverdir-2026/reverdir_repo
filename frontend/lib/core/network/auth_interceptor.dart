import 'package:dio/dio.dart';

import 'api_endpoints.dart';

/// JWT Bearer 자동 주입 + 401 시 refresh 후 재시도.
///
/// 흐름:
/// 1. [onRequest] — 공개 경로 제외, Access Token → `Authorization: Bearer …`
/// 2. [onError] 401 — [ApiEndpoints.authRefresh] 호출 → 토큰 저장 → 원 요청 재시도
/// 3. refresh 실패 — [onTokenInvalidated] 호출 후 에러 전파
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required AuthTokenProvider tokenProvider,
    this.onTokenInvalidated,
  })  : _dio = dio,
        _tokenProvider = tokenProvider;

  final Dio _dio;
  final AuthTokenProvider _tokenProvider;
  final void Function()? onTokenInvalidated;

  Future<void>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (ApiEndpoints.isPublicPath(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _tokenProvider.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;

    if (!isUnauthorized ||
        ApiEndpoints.isPublicPath(path) ||
        path == ApiEndpoints.authRefresh) {
      handler.next(err);
      return;
    }

    try {
      final retried = await _refreshAndRetry(err.requestOptions);
      handler.resolve(retried);
    } on DioException catch (refreshError) {
      await _tokenProvider.clearTokens();
      onTokenInvalidated?.call();
      handler.next(refreshError);
    }
  }

  Future<Response<dynamic>> _refreshAndRetry(RequestOptions failed) async {
    if (_refreshCompleter != null) {
      await _refreshCompleter;
      return _retry(failed);
    }

    _refreshCompleter = _performRefresh(failed);
    try {
      await _refreshCompleter;
      return _retry(failed);
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _performRefresh(RequestOptions failed) async {
    final refreshToken = await _tokenProvider.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw DioException(
        requestOptions: failed,
        response: Response(
          requestOptions: failed,
          statusCode: 401,
          statusMessage: 'Refresh token missing',
        ),
      );
    }

    final refreshResponse = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
    );

    final data = refreshResponse.data;
    final access = data?['accessToken'] as String?;
    final refresh = data?['refreshToken'] as String?;

    if (access == null || access.isEmpty) {
      throw DioException(
        requestOptions: failed,
        response: refreshResponse,
      );
    }

    await _tokenProvider.writeTokens(
      accessToken: access,
      refreshToken: refresh ?? refreshToken,
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions failed) async {
    final accessToken = await _tokenProvider.readAccessToken();
    final headers = Map<String, dynamic>.from(failed.headers);
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final options = Options(
      method: failed.method,
      headers: headers,
      responseType: failed.responseType,
      contentType: failed.contentType,
      extra: failed.extra,
      validateStatus: failed.validateStatus,
    );

    return _dio.request<dynamic>(
      failed.path,
      data: failed.data,
      queryParameters: failed.queryParameters,
      options: options,
    );
  }
}

/// SecureStorage 등 토큰 저장소 — [DioClient.init] 시 주입.
abstract class AuthTokenProvider {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

/// 개발·테스트용 인메모리 구현
class InMemoryAuthTokenProvider implements AuthTokenProvider {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
