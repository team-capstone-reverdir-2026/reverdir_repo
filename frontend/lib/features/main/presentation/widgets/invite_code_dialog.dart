import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class InviteCodeDialog extends StatefulWidget {
  const InviteCodeDialog({super.key});

  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.CIvory,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
      title: Text('초대 코드 입력', style: AppTextStyles.titleSmall),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: 36,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                maxLength: 1,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.CBackground,
                  border: AppTheme.handDrawnOutline(color: AppColors.CBrown),
                ),
                onChanged: (v) {
                  if (v.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                  if (v.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  setState(() {});
                },
              ),
            ),
          );
        }),
      ),
      actions: [
        CustomButton(
          label: '입장',
          onPressed:
              _code.length == 6 ? () => Navigator.pop(context, _code) : null,
          width: 120,
        ),
      ],
    );
  }

  String get _code =>
      _controllers.map((e) => e.text.trim()).join().toUpperCase();
}
