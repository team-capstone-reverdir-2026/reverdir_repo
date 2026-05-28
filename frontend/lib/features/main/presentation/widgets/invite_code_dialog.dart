import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

/// 초대 코드 6자리 — 단일 [TextField] + 표시 칸(OTP) 패턴.
class InviteCodeDialog extends StatefulWidget {
  const InviteCodeDialog({super.key});

  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog> {
  static const _codeLength = 6;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _code => _controller.text.trim().toUpperCase();

  @override
  Widget build(BuildContext context) {
    final code = _code;
    final hasFocus = _focusNode.hasFocus;

    return AlertDialog(
      backgroundColor: AppColors.CIvory,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
      title: Text('초대 코드 입력', style: AppTextStyles.titleSmall),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '영문·숫자 6자리',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.CTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_codeLength, (index) {
                      final char =
                          index < code.length ? code[index] : null;
                      final isActive =
                          hasFocus && index == code.length.clamp(0, _codeLength);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _CodeCell(
                          char: char,
                          isActive: isActive,
                          isFilled: char != null,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLength: _codeLength,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 1,
                      height: 1,
                    ),
                    cursorColor: Colors.transparent,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9]'),
                      ),
                      LengthLimitingTextInputFormatter(_codeLength),
                      _UpperCaseFormatter(),
                    ],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (_code.length == _codeLength) {
                        Navigator.pop(context, _code);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        CustomButton(
          label: '입장',
          onPressed: _code.length == _codeLength
              ? () => Navigator.pop(context, _code)
              : null,
          width: 120,
        ),
      ],
    );
  }
}

class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.char,
    required this.isActive,
    required this.isFilled,
  });

  final String? char;
  final bool isActive;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 40,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.CBackground,
        borderRadius: BorderRadius.circular(12),
        border: AppTheme.handDrawnBorder(
          color: isActive
              ? AppColors.CRed
              : isFilled
                  ? AppColors.COrange
                  : AppColors.CBrown,
          width: isActive ? AppTheme.borderWidthFocus : AppTheme.borderWidth,
        ),
      ),
      child: Text(
        char ?? '',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.CTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
