import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthResponseData {
  const AuthResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.username,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String username;

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    return AuthResponseData(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: user['id'] as String? ?? '',
      name: user['name'] as String? ?? '',
      username: user['username'] as String? ?? '',
    );
  }
}

class AuthRepository {
  const AuthRepository({ApiClient? client}) : _client = client;

  final ApiClient? _client;

  ApiClient get _api => _client ?? apiClient;

  Future<AuthResponseData> login({
    required String username,
    required String password,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {
        'username': username,
        'password': password,
      },
    );
    return AuthResponseData.fromJson(res.data ?? const {});
  }

  Future<AuthResponseData> register({
    required String name,
    required String username,
    required String password,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      data: {
        'name': name,
        'username': username,
        'password': password,
      },
    );
    return AuthResponseData.fromJson(res.data ?? const {});
  }
}
