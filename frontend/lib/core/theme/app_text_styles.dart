import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 텍스트 스타일 (doc/api-docs.json UI 라벨·본문 대응).
///
/// - RoomSummary.name → [roomName]
/// - RoomStatus.displayLabel → [statusBadge]
/// - ErrorResponse.message → [errorMessage]
/// - Note.content / Mission.content → [bodyMedium]
///
/// [fontFamily]만 바꾸면 모든 스타일에 귀여운 한글 폰트를 일괄 적용할 수 있습니다.
class AppTextStyles {
  AppTextStyles._();

  // ── 폰트 패밀리 (일괄 변경 가이드) ─────────────────────────────────────
  // 지금은 `null` → Flutter 기본(시스템) 폰트.
  //
  // 커스텀 에셋 폰트:
  //   1. pubspec.yaml `fonts:` 에 패밀리 등록
  //   2. 아래를 예: `static const String? fontFamily = 'MyCuteFont';`
  //
  // Google Fonts (google_fonts 패키지):
  //   - Gaegu:        GoogleFonts.gaeguTextTheme() / fontFamily: 'Gaegu'
  //   - Gamja Flower: fontFamily: 'Gamja Flower'
  //   - Poor Story:   fontFamily: 'Poor Story'
  //
  // 적용 예:
  //   static const String? fontFamily = 'Gaegu';
  static const String? fontFamily = null;

  // ── Display — 스플래시·온보딩·큰 환영 문구 ─────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.28,
    letterSpacing: -0.3,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  // ── Title — 화면·섹션·카드 제목 ───────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  // ── Body — 본문·설명·리스트 ─────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  /// 기본 본문 (가장 자주 사용)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.15,
    color: AppColors.CTextSecondary,
    fontFamily: fontFamily,
  );

  // ── Caption · Label — 메타·힌트·뱃지·탭 ─────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.CTextTertiary,
    fontFamily: fontFamily,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
    color: AppColors.CTextSecondary,
    fontFamily: fontFamily,
  );

  /// RoomStatus · ReportStatus · Note.direction 뱃지
  static const TextStyle statusBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.15,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  /// GET /rooms — RoomSummary.name
  static const TextStyle roomName = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  /// ErrorResponse.message · 스낵바/다이얼로그
  static const TextStyle errorMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.CBackground,
    fontFamily: fontFamily,
  );

  // ── UI 전용 — 버튼·입력·링크 ───────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle input = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.CTextPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.CRed,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.CRed,
    fontFamily: fontFamily,
  );

  /// 비활성·빈 상태 문구
  static const TextStyle disabled = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.CTextDisabled,
    fontFamily: fontFamily,
  );
}
