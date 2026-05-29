import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../manitto_game/data/game_repository.dart';

/// 유형명 + 문장부호를 한 덩어리로 줄바꿈 (느낌표 단독 다음 줄 방지).
class _TypeNameHeading extends StatelessWidget {
  const _TypeNameHeading({required this.typeName});

  final String typeName;

  static final _trailingPunct = RegExp(r'[!?？！？…]+$');

  @override
  Widget build(BuildContext context) {
    final trimmed = typeName.trim();
    final match = _trailingPunct.firstMatch(trimmed);
    final base = match == null ? trimmed : trimmed.substring(0, match.start);
    final suffix = match == null ? '!' : trimmed.substring(match.start);

    return Text.rich(
      TextSpan(
        style: AppTextStyles.displayMedium,
        children: [
          TextSpan(
            text: base,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.CPurple,
            ),
          ),
          TextSpan(
            // WORD JOINER — 부호가 앞 글자/단어와 분리되어 줄바꿈되지 않게 함
            text: '\u2060$suffix',
            style: AppTextStyles.displayMedium.copyWith(
              color: suffix == '!' ? AppColors.CRed : AppColors.CPurple,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _TypeNameHeading(typeName: report.typeName),
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
                  child: Center(
                    child: Image.asset(
                      'assets${report.typeImageUrl}',
                      width: 132,
                      height: 132,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('이미지 준비중', style: TextStyle(color: Colors.grey));
                      },
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
