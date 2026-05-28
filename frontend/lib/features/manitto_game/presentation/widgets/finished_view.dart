import 'package:flutter/material.dart';

import '../../../../core/network/api_enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/tomato_mascot.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../data/mock_game_service.dart';

class FinishedView extends StatelessWidget {
  const FinishedView({
    super.key,
    required this.service,
    required this.onOpenLetters,
    required this.onOpenResults,
  });

  final MockGameService service;
  final VoidCallback onOpenLetters;
  final VoidCallback onOpenResults;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 132),
      children: [
        Transform.rotate(
          angle: -0.014,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.CPurple.withValues(alpha: 0.42),
                      AppColors.CPink.withValues(alpha: 0.30),
                      AppColors.CIvory,
                    ],
                  ),
                  borderRadius: AppTheme.borderRadius,
                  border: AppTheme.handDrawnBorder(color: AppColors.CPurple),
                ),
                child: Column(
                  children: [
                    const TomatoMascot(
                      variant: TomatoMascotVariant.excited,
                      size: 86,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '마니또 게임 종료!',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.CPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '새 미션과 쪽지 보내기는 잠겼지만, 추억과 결과 리포트는 열려 있어요.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -10,
                right: 28,
                child: WashiTape.horizontal(
                  color: WashiTapeColor.pink,
                  width: 90,
                  rotation: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _LockedSection(service: service),
        const SizedBox(height: 22),
        CustomButton(
          label: '쪽지함 들어가기',
          onPressed: onOpenLetters,
          variant: CustomButtonVariant.outlined,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: '결과 보기',
          onPressed: onOpenResults,
          width: double.infinity,
        ),
      ],
    );
  }
}

class _LockedSection extends StatelessWidget {
  const _LockedSection({required this.service});

  final MockGameService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.CBrown.withValues(alpha: 0.22),
        borderRadius: AppTheme.borderRadius,
        border: AppTheme.handDrawnBorder(color: AppColors.CBrown),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, color: AppColors.CTextSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '상호작용 잠금',
                  style: AppTextStyles.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '미션 입력/수정/삭제와 새 쪽지 전송은 종료된 방에서는 사용할 수 없어요.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.CTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '참여자 ${service.participants.length}명 · 받은 쪽지 ${service.letters.where((n) => n.direction == NoteDirection.received).length}개',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
