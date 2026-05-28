import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../provider/hint_provider.dart';
import 'hint_blur.dart';

/// 오늘의 질문 카드 — GET .../questions/today
class HintCard extends StatefulWidget {
  const HintCard({
    super.key,
    required this.roomId,
    required this.data,
    this.onAnswerSubmitted,
  });

  final String roomId;
  final TodayQuestionViewData data;

  /// TODO: POST .../questions/today/answer 연동
  final ValueChanged<String>? onAnswerSubmitted;

  @override
  State<HintCard> createState() => _HintCardState();
}

class _HintCardState extends State<HintCard> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactAnswer = constraints.maxWidth < 340;

        return Transform.rotate(
          angle: -0.018,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.roomHintsPath(widget.roomId)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.CYellow.withValues(alpha: 0.82),
                        AppColors.CPink.withValues(alpha: 0.50),
                        AppColors.CIvory,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: AppTheme.handDrawnBorder(
                      color: AppColors.COrange.withValues(alpha: 0.75),
                      width: AppTheme.borderWidthFocus,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.COrange.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QuestionBadge(questionText: data.content),
                      const SizedBox(height: 18),
                      _AnswerPair(
                        data: data,
                        controller: _answerController,
                        compact: useCompactAnswer,
                        onAnswerSubmitted: widget.onAnswerSubmitted,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -10,
                  right: 24,
                  child: WashiTape.horizontal(
                    color: WashiTapeColor.orange,
                    width: 78,
                    rotation: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({required this.questionText});

  final String questionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.CBackground.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: AppTheme.handDrawnBorder(
          color: AppColors.CRed.withValues(alpha: 0.45),
          width: AppTheme.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.CRed.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '오늘의 질문',
              style: AppTextStyles.label.copyWith(
                color: AppColors.CBackground,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            questionText,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.CTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnswerPair extends StatelessWidget {
  const _AnswerPair({
    required this.data,
    required this.controller,
    required this.compact,
    this.onAnswerSubmitted,
  });

  final TodayQuestionViewData data;
  final TextEditingController controller;
  final bool compact;
  final ValueChanged<String>? onAnswerSubmitted;

  @override
  Widget build(BuildContext context) {
    final me = _buildMyAnswer();
    final manitto = _buildManittoAnswer();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: me),
        SizedBox(width: compact ? 8 : 12),
        Expanded(child: manitto),
      ],
    );
  }

  Widget _buildMyAnswer() {
    if (!data.myAnswered) {
      return _AnswerBubble(
        label: '나',
        labelColor: AppColors.CYellow,
        backgroundColor: AppColors.CBackground,
        content: '답을 입력해주세요!',
        child: CustomTextField(
          controller: controller,
          hint: '답변 쓰기',
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().isEmpty) return;
            onAnswerSubmitted?.call(value.trim());
            // TODO: POST answer 후 HintProvider 갱신
          },
        ),
      );
    }

    return _AnswerBubble(
      label: '나',
      labelColor: AppColors.CYellow,
      backgroundColor: AppColors.CIvory,
      content: data.myAnswerContent ?? '',
    );
  }

  Widget _buildManittoAnswer() {
    if (!data.manittoAnswered) {
      return _AnswerBubble(
        label: '마',
        labelColor: AppColors.CSkyBlue,
        backgroundColor: AppColors.CBlue.withValues(alpha: 0.16),
        content: '마니또가 고민 중이에요…',
        muted: true,
      );
    }

    final bubble = _AnswerBubble(
      label: '마',
      labelColor: AppColors.CSkyBlue,
      backgroundColor: AppColors.CSkyBlue.withValues(alpha: 0.25),
      content: data.manittoAnswerContent ?? '',
      muted: data.shouldBlurManittoAnswer,
    );

    if (data.shouldBlurManittoAnswer) {
      return HintBlur(child: bubble);
    }

    return bubble;
  }
}

class _AnswerBubble extends StatelessWidget {
  const _AnswerBubble({
    required this.label,
    required this.labelColor,
    required this.backgroundColor,
    required this.content,
    this.child,
    this.muted = false,
  });

  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final String content;
  final Widget? child;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: labelColor.withValues(alpha: 0.78),
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: labelColor,
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.CTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (child != null)
            child!
          else
            Text(
              content,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                color: muted ? AppColors.CTextTertiary : AppColors.CTextPrimary,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
