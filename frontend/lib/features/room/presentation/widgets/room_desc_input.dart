import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomDescInput extends StatefulWidget {
  const RoomDescInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.apiException,
    this.onChanged,
    this.onSubmitToServer,
  });

  final TextEditingController controller;
  final bool enabled;
  final ApiException? apiException;
  final ValueChanged<String>? onChanged;

  /// 부모에서 실제 서버 API 호출 로직을 연결하세요(목업 금지).
  final Future<void> Function(String value)? onSubmitToServer;

  @override
  State<RoomDescInput> createState() => _RoomDescInputState();
}

class _RoomDescInputState extends State<RoomDescInput> {
  String? _localErrorText;

  String? get _errorText => _localErrorText;

  Future<void> _submitToServer(String value) async {
    if (widget.onSubmitToServer == null) return;
    setState(() => _localErrorText = null);
    try {
      await widget.onSubmitToServer!(value);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (!mounted) return;
      context.showUserError(e);
    } catch (e) {
      if (!mounted) return;
      context.showUserError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      minLines: 3,
      maxLines: 3,
      maxLength: 200,
      style: AppTextStyles.input,
      onChanged: widget.onChanged,
      onSubmitted: _submitToServer,
      decoration: InputDecoration(
        counterText: '',
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColors.CIvory,
        hintText: '어떤 사람들과의 모임인지 입력해 주세요',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.CTextTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.CBrown, width: 1.3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.CBrown, width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.COrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.CRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.CRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorText: _errorText,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.CRed),
      ),
    );
  }
}
