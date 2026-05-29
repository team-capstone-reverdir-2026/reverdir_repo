import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// 앱 전역 텍스트 스타일 — [GoogleFonts.poorStory] 기본 적용.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _poor({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double letterSpacing = 0,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    // GoogleFonts TextStyle 서브클래스는 Web 릴리스에서 Theme/TextField 병합 시
    // FontWeight 등 subtype 오류를 유발할 수 있어 plain TextStyle로 고정합니다.
    final google = GoogleFonts.poorStory(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
    );
    return TextStyle(
      fontFamily: google.fontFamily,
      fontFamilyFallback: google.fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle get displayLarge => _poor(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get displayMedium => _poor(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.28,
        letterSpacing: -0.3,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get titleLarge => _poor(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get titleMedium => _poor(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get titleSmall => _poor(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get bodyLarge => _poor(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.1,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get bodyMedium => _poor(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.15,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get bodySmall => _poor(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.15,
        color: AppColors.CTextSecondary,
      );

  static TextStyle get caption => _poor(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: AppColors.CTextTertiary,
      );

  static TextStyle get label => _poor(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.3,
        color: AppColors.CTextSecondary,
      );

  static TextStyle get statusBadge => _poor(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.15,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get roomName => _poor(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get errorMessage => _poor(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppColors.CBackground,
      );

  static TextStyle get button => _poor(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get input => _poor(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.CTextPrimary,
      );

  static TextStyle get link => _poor(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.CRed,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.CRed,
      );

  static TextStyle get disabled => _poor(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.CTextDisabled,
      );

  /// [ThemeData.textTheme]용 — Material 타입 스케일 매핑.
  static TextTheme get materialTextTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: titleLarge,
        headlineMedium: titleMedium,
        headlineSmall: titleSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: label,
        labelMedium: caption,
        labelSmall: caption,
      );
}
