import 'package:flutter/material.dart';

import '../network/error_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

/// [ErrorHandler] → [ApiException] 공통 에러 화면.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = '앗, 문제가 생겼어요',
  });

  /// [ApiException]에서 바로 생성
  factory ErrorView.fromApiException(
    ApiException exception, {
    Key? key,
    VoidCallback? onRetry,
    String title = '앗, 문제가 생겼어요',
  }) {
    return ErrorView(
      key: key,
      message: exception.message,
      onRetry: onRetry,
      title: title,
    );
  }

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.CPink.withValues(alpha: 0.45),
                borderRadius: AppTheme.borderRadius,
                border: AppTheme.handDrawnBorder(color: AppColors.CBrown),
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied_outlined,
                size: 44,
                color: AppColors.CTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.CTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              CustomButton(
                label: '다시 시도하기',
                onPressed: onRetry,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
