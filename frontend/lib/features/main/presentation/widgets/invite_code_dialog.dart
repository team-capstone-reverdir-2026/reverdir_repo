import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

/// 초대 코드 6자리 — 표시 칸 + 전체 영역 투명 입력.
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

  String get _code => _controller.text.trim();

  @override
  Widget build(BuildContext context) {
    final code = _code;
    final hasFocus = _focusNode.hasFocus;

    return AlertDialog(
      backgroundColor: AppColors.CIvory,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
      title: Text('초대 코드 입력', style: AppTextStyles.titleSmall),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '숫자 6자리',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.CTextSecondary,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_codeLength, (index) {
                        final char =
                            index < code.length ? code[index] : null;
                        final isActive = hasFocus &&
                            index == code.length.clamp(0, _codeLength);
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: _CodeCell(
                            char: char,
                            isActive: isActive,
                            isFilled: char != null,
                          ),
                        );
                      }),
                    ),
                    Positioned.fill(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.visiblePassword,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        showCursor: false,
                        enableInteractiveSelection: true,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 24,
                          height: 1,
                        ),
                        cursorColor: Colors.transparent,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_codeLength),
                        ],
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) {
                          if (_code.length == _codeLength) {
                            Navigator.pop(context, _code);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  label: '입장',
                  onPressed: _code.length == _codeLength
                      ? () => Navigator.pop(context, _code)
                      : null,
                  width: 120,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [],
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
    return Container(
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
