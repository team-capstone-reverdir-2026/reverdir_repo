import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// 마니또 답변 블러 오버레이 (TodayQuestion.manitoAnswer.visibleToMe == false).
///
/// [BackdropFilter] + [ImageFilter.blur] — 도화지 위 번진 감성.
class HintBlur extends StatelessWidget {
  const HintBlur({
    super.key,
    required this.child,
    this.chipLabel = '마니또가 답변했어요! (보고 싶다면 답장해주세요)',
    this.sigma = 4,
  });

  final Widget child;
  final String chipLabel;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppTheme.borderRadius,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: Container(
                color: AppColors.answerBlurOverlay(),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.CTextPrimary.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      chipLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.CBackground,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
