import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tomato_mascot.dart';
import '../../manitto_game/data/game_repository.dart';

class ReportPersonal extends StatelessWidget {
  const ReportPersonal({
    super.key,
    required this.report,
  });

  final PersonalReportData report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
      children: [
        Transform.rotate(
          angle: 0.012,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.CPurple.withValues(alpha: 0.40),
                  AppColors.CPink.withValues(alpha: 0.34),
                  AppColors.CIvory,
                ],
              ),
              borderRadius: AppTheme.borderRadius,
              border: AppTheme.handDrawnBorder(color: AppColors.CPurple),
            ),
            child: Column(
              children: [
                Text(
                  '당신은',
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  report.typeName,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.CPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '!',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.CRed,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.CYellow.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(42),
                    border: AppTheme.handDrawnBorder(color: AppColors.COrange),
                  ),
                  child: const Center(
                    child: TomatoMascot(
                      variant: TomatoMascotVariant.embarrassed,
                      size: 132,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  report.storyText,
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.65),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
