class TokenStorage {
  TokenStorage._();

  static String? _accessToken;
  static String? _refreshToken;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;

  static bool get isLoggedIn => _accessToken != null;

  static void saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  static void clear() {
    _accessToken = null;
    _refreshToken = null;
  }
}