import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// 앱 전역 스낵바 — 라우트 전환 후에도 표시 가능.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showRootSnackBar(
  String message, {
  EdgeInsets? margin,
}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  final text = message.trim();
  if (text.isEmpty) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.CTextPrimary,
        ),
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 96),
      duration: const Duration(seconds: 3),
      shape: AppTheme.roundedShape,
    ),
  );
}
