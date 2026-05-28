import 'package:flutter/material.dart';

import '../network/error_handler.dart';
import '../network/api_error_tracker.dart';
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

  /// 하단 CTA·바가 스낵바에 가리지 않도록 여백을 둡니다.
  EdgeInsets get _snackBarMargin {
    final bottom = MediaQuery.paddingOf(this).bottom;
    return EdgeInsets.fromLTRB(16, 0, 16, bottom + 96);
  }

  /// 일반·오류 안내 공통 스낵바 (흰 배경, 검은 글씨, 하단 버튼 위).
  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(this);
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
        margin: _snackBarMargin,
        shape: AppTheme.roundedShape,
      ),
    );
  }

  /// [showSnackBar]와 동일한 형태 (백엔드 메시지·검증 문구 공통).
  void showErrorSnackBar(String message) => showSnackBar(message);

  void showApiExceptionSnackBar(ApiException exception) {
    showSnackBar(ApiErrorTracker.userMessage(exception));
  }

  void showUserError(Object error) {
    showSnackBar(ApiErrorTracker.userMessage(error));
  }
}

extension StringX on String {
  bool get isNotNullOrBlank => trim().isNotEmpty;
}
