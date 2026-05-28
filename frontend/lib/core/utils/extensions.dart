import 'package:flutter/material.dart';

import '../network/error_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// BuildContext·String 편의 확장.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;

  /// 일반 안내 스낵바 (웜 크림 톤)
  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.CTextPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: AppTheme.roundedShape,
      ),
    );
  }

  /// [ApiException] / ErrorResponse.message 전용
  void showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.errorMessage),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: AppTheme.roundedShape,
      ),
    );
  }

  void showApiExceptionSnackBar(ApiException exception) {
    showErrorSnackBar(exception.message);
  }
}

extension StringX on String {
  bool get isNotNullOrBlank => trim().isNotEmpty;
}
