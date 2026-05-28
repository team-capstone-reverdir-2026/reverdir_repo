import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/auth_interceptor.dart';

/// JWT 토큰 암호화 저장 (doc/api-docs.json AuthResponse).
///
/// [AuthTokenProvider] 구현체 — [DioClient.init]에 주입:
/// ```dart
/// DioClient.instance.init(
///   tokenProvider: SecureStorageService.instance,
///   onTokenInvalidated: () => appRouter.go(AppRoutes.login),
/// );
/// ```
class SecureStorageService implements AuthTokenProvider {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// AuthResponse.accessToken
  static const String keyAccessToken = 'manitto_access_token';

  /// AuthResponse.refreshToken
  static const String keyRefreshToken = 'manitto_refresh_token';

  // ── AuthTokenProvider (network/auth_interceptor.dart) ───────────────────

  @override
  Future<String?> readAccessToken() => getAccessToken();

  @override
  Future<String?> readRefreshToken() => getRefreshToken();

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  @override
  Future<void> clearTokens() => deleteAllTokens();

  // ── 앱 전용 API ─────────────────────────────────────────────────────────

  /// POST /auth/login · /auth/register 성공 후 호출
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: keyAccessToken, value: accessToken),
      _storage.write(key: keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: keyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: keyRefreshToken);

  Future<void> deleteAllTokens() async {
    await Future.wait([
      _storage.delete(key: keyAccessToken),
      _storage.delete(key: keyRefreshToken),
    ]);
  }

  /// app_router redirect 가드용
  ///
  /// TODO: refresh 토큰 만료 정책이 정해지면 유효성 검증 로직 추가
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
