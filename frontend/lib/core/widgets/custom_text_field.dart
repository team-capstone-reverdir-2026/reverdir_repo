import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// 펠트·손그림 테두리 통일 입력창 (쪽지·미션·로그인 등).
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: hasError ? errorText : null,
        filled: true,
        fillColor: AppColors.CIvory,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.CTextTertiary,
        ),
        labelStyle: AppTextStyles.bodySmall,
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.CRed),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: AppTheme.handDrawnOutline(color: AppColors.CBrown),
        enabledBorder: AppTheme.handDrawnOutline(color: AppColors.CBrown),
        focusedBorder: AppTheme.handDrawnOutline(
          color: AppColors.CRed,
          width: AppTheme.borderWidthFocus,
        ),
        errorBorder: AppTheme.handDrawnOutline(color: AppColors.CRed),
        focusedErrorBorder: AppTheme.handDrawnOutline(
          color: AppColors.CRed,
          width: AppTheme.borderWidthFocus,
        ),
        disabledBorder: AppTheme.handDrawnOutline(
          color: AppColors.CTextDisabled,
        ),
      ),
    );
  }
}
