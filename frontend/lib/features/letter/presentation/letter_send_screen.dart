import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../data/letter_repository.dart';

const double _notebookFontSize = 17.5;
const double _notebookLineHeight = 30.0;

class LetterSendScreen extends StatefulWidget {
  const LetterSendScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<LetterSendScreen> createState() => _LetterSendScreenState();
}

class _LetterSendScreenState extends State<LetterSendScreen> {
  final _controller = TextEditingController();
  final _repo = const LetterRepository();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쪽지 쓰기'),
        leading: const AppBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: DoodleBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.CBrown.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColors.CIvory,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              AppTheme.handDrawnBorder(color: AppColors.CBrown),
                        ),
                        child: CustomPaint(
                          painter: _LinedPaperPainter(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                            child: TextField(
                              controller: _controller,
                              enabled: !_submitting,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              strutStyle: const StrutStyle(
                                fontSize: _notebookFontSize,
                                height: _notebookLineHeight / _notebookFontSize,
                                forceStrutHeight: true,
                              ),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: _notebookFontSize,
                                height: _notebookLineHeight / _notebookFontSize,
                                color: AppColors.CTextPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: _submitting
                                    ? '전송 중이에요...'
                                    : '마니띠에게 따뜻한 쪽지를 남겨보세요...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.CTextTertiary,
                                  fontSize: _notebookFontSize,
                                  height:
                                      _notebookLineHeight / _notebookFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: _submitting ? '전송 중...' : '쪽지 보내기',
                isEnabled: !_submitting,
                onPressed: _submitting
                    ? null
                    : () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) {
                          context.showErrorSnackBar('쪽지 내용을 입력해 주세요.');
                          return;
                        }
                        try {
                          setState(() => _submitting = true);
                          await _repo.send(widget.roomId, text);
                          if (!mounted) return;
                          context.showSnackBar('쪽지를 보냈어요!');
                          context.pop();
                        } catch (e) {
                          if (!mounted) return;
                          context.showUserError(e);
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final marginPaint = Paint()
      ..color = AppColors.CRed.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(14, 0),
      Offset(14, size.height),
      marginPaint,
    );

    final linePaint = Paint()
      ..color = AppColors.CBrown.withValues(alpha: 0.14)
      ..strokeWidth = 1;

    for (var y = 29.0; y < size.height; y += _notebookLineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
