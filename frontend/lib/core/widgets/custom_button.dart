import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'loading_indicator.dart';

/// 앱 공통 CTA — [AppTheme] 토마토 레드 · 조약돌 radius 24.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = CustomButtonVariant.primary,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final CustomButtonVariant variant;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      child: switch (variant) {
        CustomButtonVariant.primary => ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.CRed,
              foregroundColor: AppColors.CBackground,
              disabledBackgroundColor:
                  AppColors.CBrown.withValues(alpha: 0.55),
              disabledForegroundColor:
                  AppColors.CBackground.withValues(alpha: 0.75),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              minimumSize: const Size(64, 52),
              shape: AppTheme.roundedShape,
              textStyle: AppTextStyles.button.copyWith(
                color: AppColors.CBackground,
              ),
            ),
            child: _buildChild(),
          ),
        CustomButtonVariant.outlined => OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.CTextPrimary,
              side: AppTheme.handDrawnBorderSide(
                color: AppColors.CTextSecondary,
              ),
              shape: AppTheme.roundedShape,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              textStyle: AppTextStyles.button,
            ),
            child: _buildChild(),
          ),
        CustomButtonVariant.text => TextButton(
            onPressed: enabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.CRed,
              shape: AppTheme.roundedShape,
              textStyle: AppTextStyles.link.copyWith(
                decoration: TextDecoration.none,
              ),
            ),
            child: _buildChild(),
          ),
      },
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const LoadingIndicatorSmall();
    }
    return Text(label);
  }
}

enum CustomButtonVariant { primary, outlined, text }
