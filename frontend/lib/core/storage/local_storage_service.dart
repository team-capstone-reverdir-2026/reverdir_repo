import 'package:shared_preferences/shared_preferences.dart';

/// 단순 앱 설정 로컬 저장 (JWT 제외 — [SecureStorageService] 사용).
class LocalStorageService {
  LocalStorageService._();

  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  static Future<LocalStorageService> getInstance() async {
    if (_instance != null) return _instance!;
    _prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService._();
    return _instance!;
  }

  SharedPreferences get prefs {
    final value = _prefs;
    if (value == null) {
      throw StateError(
        'Call LocalStorageService.getInstance() before use.',
      );
    }
    return value;
  }

  // ── Keys ──────────────────────────────────────────────────────────────────

  /// 최초 실행 온보딩 완료 여부
  static const String keyOnboardingCompleted = 'onboarding_completed';

  /// 테마 모드 (현재 앱은 라이트 고정, 확장용)
  /// TODO: 다크/시스템 테마 지원 시 AppTheme.dark 연동
  static const String keyThemeMode = 'theme_mode';

  // ── Onboarding ──────────────────────────────────────────────────────────

  Future<bool> isOnboardingCompleted() async =>
      prefs.getBool(keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted({bool value = true}) async {
    await prefs.setBool(keyOnboardingCompleted, value);
  }

  // ── Theme (스켈레톤) ────────────────────────────────────────────────────

  /// 저장값: `light` | `dark` | `system` (기본 `light`)
  Future<String> getThemeMode() async =>
      prefs.getString(keyThemeMode) ?? 'light';

  Future<void> setThemeMode(String mode) async {
    await prefs.setString(keyThemeMode, mode);
  }
}
