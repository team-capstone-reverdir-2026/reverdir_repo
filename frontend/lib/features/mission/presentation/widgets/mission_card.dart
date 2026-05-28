import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tomato_mascot.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../provider/mission_provider.dart';

/// 미션 목록 카드 — PATCH .../missions/{missionId} isCompleted
class MissionListCard extends StatelessWidget {
  const MissionListCard({
    super.key,
    required this.provider,
    this.showMascot = true,
  });

  final MissionProvider provider;
  final bool showMascot;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.016,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.CGreen.withValues(alpha: 0.42),
                  AppColors.CSkyBlue.withValues(alpha: 0.20),
                  AppColors.CIvory,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: AppTheme.handDrawnBorder(
                color: AppColors.CGreen.withValues(alpha: 0.82),
                width: AppTheme.borderWidthFocus,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.CGreen.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '오늘의 미션',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.CTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showMascot) ...[
                      const SizedBox(width: 8),
                      const TomatoMascot(
                        variant: TomatoMascotVariant.scribbling,
                        size: 32,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                ...provider.missions.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MissionCard(
                      mission: m,
                      onToggle: () => provider.toggleMission(m.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -12,
            left: 24,
            child: WashiTape.horizontal(
              color: WashiTapeColor.green,
              width: 88,
              rotation: -7,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.mission,
    required this.onToggle,
  });

  final MissionUiItem mission;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HandDrawnCheckbox(isChecked: mission.isCompleted),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              style: AppTextStyles.bodyLarge.copyWith(
                color: mission.isCompleted
                    ? AppColors.CTextTertiary
                    : AppColors.CTextPrimary,
                decoration: mission.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: AppColors.CTextPrimary.withValues(alpha: 0.4),
                decorationThickness: 2,
              ),
              child: Text(mission.content),
            ),
          ),
        ],
      ),
    );
  }
}

class _HandDrawnCheckbox extends StatelessWidget {
  const _HandDrawnCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: 26,
      height: 26,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: isChecked
            ? AppColors.CRed.withValues(alpha: 0.20)
            : AppColors.CBackground.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.CTextPrimary,
          width: AppTheme.borderWidthFocus,
        ),
      ),
      child: AnimatedOpacity(
        opacity: isChecked ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: CustomPaint(
          size: const Size(26, 26),
          painter: _CheckMarkPainter(),
        ),
      ),
    );
  }
}

class _CheckMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.CRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.78)
      ..lineTo(size.width * 0.82, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
