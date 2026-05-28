import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_enums.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Manitto(doc/api-docs.json) 통합 테마 — 파스텔·펠트·손그림 선.
///
/// [AppTheme.light] + [roomStatusBadge] 등 API enum 시맨틱 헬퍼를 사용합니다.
/// 바느질·색연필 텍스처는 위젯에서 [borderRadius]·[handDrawnBorder] 기준으로 CustomPaint/DecorationImage 적용.
class AppTheme {
  AppTheme._();

  // ── 전역 형태·선 (또마니또 시그니처) ─────────────────────────────────────

  /// 조약돌형 둥근 모서리 — 버튼·카드·다이얼로그·입력창 공통
  static const double cornerRadius = 24;

  /// 손으로 꾹 눌러 그린 듯한 기본 테두리 두께
  static const double borderWidth = 1.5;

  /// 포커스·강조 시 조금 더 도톰한 선 (색연필을 세게 누른 느낌)
  static const double borderWidthFocus = 2.0;

  static final BorderRadius borderRadius =
      BorderRadius.circular(cornerRadius);

  static final RoundedRectangleBorder roundedShape =
      RoundedRectangleBorder(borderRadius: borderRadius);

  /// 따뜻한 손그림 테두리 — CBrown(기본) / CTextSecondary(보조)
  static Border handDrawnBorder({
    Color color = AppColors.CBrown,
    double width = borderWidth,
  }) =>
      Border.all(color: color, width: width);

  static BorderSide handDrawnBorderSide({
    Color color = AppColors.CBrown,
    double width = borderWidth,
  }) =>
      BorderSide(color: color, width: width);

  static OutlineInputBorder handDrawnOutline({
    Color color = AppColors.CBrown,
    double width = borderWidth,
  }) =>
      OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: handDrawnBorderSide(color: color, width: width),
      );

  /// 라이트 테마 (앱 기본)
  static ThemeData get light {
    final colorScheme = _buildColorScheme();
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // ── 1. 배경 — 포근한 웜 크림 종이 (CBackground) ─────────────────────
      scaffoldBackgroundColor: AppColors.CBackground,
      canvasColor: AppColors.CBackground,
      primaryTextTheme: textTheme,
      applyElevationOverlayColor: false,
      splashFactory: InkRipple.splashFactory,

      // ── 2. AppBar — 플랫, 그림자 없음, 화면과 한 장의 종이 ───────────────
      // 완전 투명이 필요하면 개별 화면에서
      // `backgroundColor: Colors.transparent`, `elevation: 0` 오버라이드.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.CBackground,
        foregroundColor: AppColors.CTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.CTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── 3. 카드 — CIvory + 도톰한 CBrown 손그림 테두리 ─────────────────
      // 스티치 효과: 위젯에서 Stack + CustomPaint로 roundedShape 경로 따라 그리기
      cardTheme: CardThemeData(
        color: AppColors.CIvory,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: handDrawnBorderSide(
            color: AppColors.CBrown,
            width: borderWidth,
          ),
        ),
      ),

      // ── 4. 시그니처 CTA — 토마토 레드 펠트 단추 ─────────────────────────
      // 눌림·비활성도 파스텔 톤을 유지 (딱딱한 회색 금지)
      elevatedButtonTheme: ElevatedButtonThemeData(style: _ctaButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: _ctaButtonStyle),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.CTextPrimary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          minimumSize: WidgetStateProperty.all(const Size(64, 48)),
          shape: WidgetStateProperty.all(roundedShape),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return handDrawnBorderSide(
                color: AppColors.CTextDisabled,
                width: borderWidth,
              );
            }
            if (states.contains(WidgetState.pressed)) {
              return handDrawnBorderSide(
                color: AppColors.COrange,
                width: borderWidthFocus,
              );
            }
            return handDrawnBorderSide(
              color: AppColors.CTextSecondary,
              width: borderWidth,
            );
          }),
          textStyle: WidgetStateProperty.all(AppTextStyles.button),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.CRed,
          shape: roundedShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTextStyles.link.copyWith(decoration: TextDecoration.none),
        ),
      ),

      // ── 5. 입력창 — 쪽지(CIvory) + 큰 둥근 모서리 + 손그림 선 ───────────
      // 포커스: CRed 도톰 선 / 비포커스: CBrown (위젯에서 스티치 오버레이 가능)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.CIvory,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.CTextTertiary,
        ),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.CTextSecondary,
        ),
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.CRed),
        border: handDrawnOutline(color: AppColors.CBrown),
        enabledBorder: handDrawnOutline(color: AppColors.CBrown),
        disabledBorder: handDrawnOutline(
          color: AppColors.CTextDisabled,
          width: borderWidth,
        ),
        focusedBorder: handDrawnOutline(
          color: AppColors.CRed,
          width: borderWidthFocus,
        ),
        errorBorder: handDrawnOutline(
          color: AppColors.CRed,
          width: borderWidth,
        ),
        focusedErrorBorder: handDrawnOutline(
          color: AppColors.CRed,
          width: borderWidthFocus,
        ),
      ),

      // ── 6. 다이얼로그 · 시트 · 스낵바 ───────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.CIvory,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: handDrawnBorderSide(
            color: AppColors.CTextSecondary,
            width: borderWidthFocus,
          ),
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.CIvory,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadius),
          ),
          side: handDrawnBorderSide(
            color: AppColors.CBrown,
            width: borderWidth,
          ),
        ),
      ),

      // 일반 안내 — ErrorResponse는 [errorSnackBarDecoration] 사용 권장
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.CTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: roundedShape,
      ),

      // ── 7. 기타 컴포넌트 ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.CBrown.withValues(alpha: 0.45),
        thickness: borderWidth,
        space: borderWidth,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.CTextPrimary,
        size: 24,
      ),

      // FAB도 각진 원 대신 뭉툭한 둥근 사각 (조약돌)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.CRed,
        foregroundColor: AppColors.CBackground,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.CBackground,
        selectedItemColor: AppColors.CRed,
        unselectedItemColor: AppColors.CTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.label,
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.CBackground,
        indicatorColor: AppColors.COrange.withValues(alpha: 0.35),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(color: AppColors.CRed);
          }
          return AppTextStyles.caption;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.CRed, size: 24);
          }
          return const IconThemeData(color: AppColors.CTextTertiary, size: 24);
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.CIvory,
        selectedColor: AppColors.COrange.withValues(alpha: 0.45),
        labelStyle: AppTextStyles.label,
        secondaryLabelStyle: AppTextStyles.caption,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: roundedShape,
        side: handDrawnBorderSide(
          color: AppColors.CTextSecondary,
          width: borderWidth,
        ),
      ),

      // MyReport.status == PENDING 폴링 (GET .../results/my-report 202)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.COrange,
        linearTrackColor: AppColors.CIvory,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.CRed;
          return AppColors.CIvory;
        }),
        checkColor: WidgetStateProperty.all(AppColors.CBackground),
        side: handDrawnBorderSide(
          color: AppColors.CTextSecondary,
          width: borderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.CBackground;
          }
          return AppColors.CIvory;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.CRed;
          return AppColors.CBrown.withValues(alpha: 0.55);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.CRed;
          }
          return AppColors.CTextSecondary;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.CTextSecondary,
        textColor: AppColors.CTextPrimary,
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.CIvory,
        elevation: 0,
        shape: roundedShape,
        textStyle: AppTextStyles.bodyMedium,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.CTextPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.caption.copyWith(
          color: AppColors.CBackground,
        ),
      ),
    );
  }

  /// 토마토 레드 CTA — 펠트 인형처럼 눌림·비활성도 파스텔 유지
  static ButtonStyle get _ctaButtonStyle => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            // 비활성: 차가운 회색 대신 웜 샌드·펠트 느낌
            return AppColors.CBrown.withValues(alpha: 0.55);
          }
          if (states.contains(WidgetState.pressed)) {
            // 눌림: 토마토가 살짝 납작해진 느낌 (레드 + 오렌지 블렌드)
            return Color.lerp(AppColors.CRed, AppColors.COrange, 0.35)!;
          }
          return AppColors.CRed;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.CBackground.withValues(alpha: 0.75);
          }
          return AppColors.CBackground;
        }),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        minimumSize: WidgetStateProperty.all(const Size(64, 52)),
        shape: WidgetStateProperty.all(roundedShape),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return AppTextStyles.button.copyWith(
            color: states.contains(WidgetState.disabled)
                ? AppColors.CBackground.withValues(alpha: 0.75)
                : AppColors.CBackground,
          );
        }),
      );

  static ColorScheme _buildColorScheme() {
    return const ColorScheme.light(
      primary: AppColors.CRed,
      onPrimary: AppColors.CBackground,
      secondary: AppColors.COrange,
      onSecondary: AppColors.CTextPrimary,
      tertiary: AppColors.CSkyBlue,
      onTertiary: AppColors.CTextPrimary,
      surface: AppColors.CBackground,
      onSurface: AppColors.CTextPrimary,
      surfaceContainerHighest: AppColors.CIvory,
      onSurfaceVariant: AppColors.CTextSecondary,
      outline: AppColors.CBrown,
      outlineVariant: AppColors.CIvory,
      error: AppColors.CRed,
      onError: AppColors.CBackground,
    );
  }

  // ── API enum 뱃지·장식 (doc/api-docs.json) ─────────────────────────────

  /// RoomSummary.status / RoomDetail.status 뱃지
  static BoxDecoration roomStatusBadge(RoomStatus status) => BoxDecoration(
        color: AppColors.roomStatusBackground(status),
        borderRadius: BorderRadius.circular(cornerRadius * 0.75),
        border: handDrawnBorder(
          color: AppColors.CBrown,
          width: borderWidth,
        ),
      );

  static TextStyle roomStatusLabel(RoomStatus status) =>
      AppTextStyles.statusBadge.copyWith(
        color: AppColors.roomStatusForeground(status),
      );

  /// MyReport.status (PENDING / READY)
  static BoxDecoration reportStatusBadge(ReportStatus status) => BoxDecoration(
        color: AppColors.reportStatusBackground(status),
        borderRadius: BorderRadius.circular(cornerRadius * 0.75),
        border: handDrawnBorder(color: AppColors.CBrown),
      );

  static TextStyle reportStatusLabel(ReportStatus status) =>
      AppTextStyles.statusBadge.copyWith(
        color: AppColors.reportStatusForeground(status),
      );

  /// Note.direction (쪽지함 탭·리스트)
  static BoxDecoration noteDirectionBadge(NoteDirection direction) =>
      BoxDecoration(
        color: AppColors.noteDirectionAccent(direction),
        borderRadius: BorderRadius.circular(cornerRadius * 0.75),
        border: handDrawnBorder(color: AppColors.CBrown),
      );

  /// ErrorResponse — SnackBar·AlertDialog
  static SnackBarThemeData get errorSnackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.error,
        contentTextStyle: AppTextStyles.errorMessage,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: roundedShape,
      );

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.titleLarge,
      headlineMedium: AppTextStyles.titleMedium,
      headlineSmall: AppTextStyles.titleSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption,
    );
  }
}
