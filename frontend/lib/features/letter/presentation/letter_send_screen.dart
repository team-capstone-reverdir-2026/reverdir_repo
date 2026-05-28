import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../manitto_game/data/mock_game_service.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = MockGameService.instance;
    final isLocked = service.phase == GamePhase.finished;

    return Scaffold(
      appBar: AppBar(title: const Text('쪽지 쓰기')),
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
                      top: -6,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(46, 22, 20, 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.CIvory,
                              AppColors.CYellow.withValues(alpha: 0.14),
                              AppColors.CIvory.withValues(alpha: 0.96),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border:
                              AppTheme.handDrawnBorder(color: AppColors.CBrown),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.CBrown.withValues(alpha: 0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _LinedPaperPainter(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
                            child: TextField(
                              controller: _controller,
                              enabled: !isLocked,
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
                                hintText: isLocked
                                    ? '종료된 방에서는 새 쪽지를 보낼 수 없어요.'
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
                    Positioned(
                      left: 18,
                      top: 28,
                      bottom: 28,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          7,
                          (_) => Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.CBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.CBrown.withValues(alpha: 0.45),
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
                label: isLocked ? '쪽지 보내기 잠김' : '쪽지 보내기',
                isEnabled: !isLocked,
                onPressed: isLocked
                    ? null
                    : () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) {
                          context.showErrorSnackBar('쪽지 내용을 입력해 주세요.');
                          return;
                        }
                        service.sendLetter(text);
                        context.showSnackBar('쪽지를 보냈어요!');
                        context.pop();
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
    final texturePaint = Paint()
      ..color = AppColors.CBrown.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;
    for (var x = 4.0; x < size.width; x += 22) {
      for (var y = 8.0; y < size.height; y += 26) {
        canvas.drawCircle(Offset(x, y), 0.8, texturePaint);
      }
    }

    final marginPaint = Paint()
      ..color = AppColors.CRed.withValues(alpha: 0.30)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      const Offset(10, 0),
      Offset(10, size.height),
      marginPaint,
    );

    final paint = Paint()
      ..color = AppColors.CSkyBlue.withValues(alpha: 0.34)
      ..strokeWidth = 1;

    for (var y = 29.0; y < size.height; y += _notebookLineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
