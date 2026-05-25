import 'package:dio/dio.dart';

import 'dio_client.dart';
import 'error_handler.dart';

/// Feature → API 유일 창구 (Dio 직접 사용 금지).
///
/// 모든 HTTP 호출은 [ApiEndpoints] 경로 + [ErrorHandler] 가공 예외를 따릅니다.
/// ```text
/// Feature Repository
///   → ApiClient.get/post/…(ApiEndpoints.xxx)
///     → DioClient.dio
///       → AuthInterceptor (JWT / refresh)
///     ← DioException → ErrorHandler → ApiException
/// ```
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _request<T>(
    Future<Response<T>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ErrorHandler.fromDioException(e);
    }
  }
}

/// 앱 전역 싱글톤 — [DioClient.init] 이후 사용
ApiClient get apiClient => ApiClient();
