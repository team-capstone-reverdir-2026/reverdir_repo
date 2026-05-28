import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomNameInput extends StatelessWidget {
  const RoomNameInput({
    super.key,
    required this.controller,
    this.apiException,
    this.enabled = true,
    this.onChanged,
  });
  final TextEditingController controller;
  final ApiException? apiException;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  String? _buildErrorText() {
    if (apiException == null) return null;
    return 'API 호출/응답 문제: ${apiException!.message}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          maxLength: 50, // 서버 스펙에 maxLength 명시는 없지만 과도한 입력 보호
          style: AppTextStyles.input,
          cursorColor: AppColors.CBrown,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.CIvory,
            hintText: '방의 이름을 입력해 주세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.CTextTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.CBrown,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.CBrown,
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.COrange,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.CRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.CRed,
                width: 2.0,
              ),
            ),
            errorText: _buildErrorText(),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.CRed),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}