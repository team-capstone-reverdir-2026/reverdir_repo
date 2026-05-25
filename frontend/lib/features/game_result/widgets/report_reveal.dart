import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/tomato_mascot.dart';
import '../../manitto_game/data/mock_game_service.dart';

class ReportReveal extends StatelessWidget {
  const ReportReveal({
    super.key,
    required this.service,
    required this.onNext,
  });

  final MockGameService service;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
      children: [
        _RevealCard(service: service),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.CIvory.withValues(alpha: 0.92),
            borderRadius: AppTheme.borderRadius,
            border: AppTheme.handDrawnBorder(color: AppColors.CSkyBlue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('전체 결과 관계도', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),
              _ChainView(chain: service.chain),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: '내 결과 분석 리포트 보러가기',
          onPressed: onNext,
          width: double.infinity,
        ),
      ],
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({required this.service});

  final MockGameService service;

  @override
  Widget build(BuildContext context) {
    final backgroundAnswers = service.questionHistory
        .map((q) => q.manittoAnswer)
        .whereType<String>()
        .take(3)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.CIvory.withValues(alpha: 0.92),
        borderRadius: AppTheme.borderRadius,
        border: AppTheme.handDrawnBorder(color: AppColors.CPurple),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RevealBackgroundPainter(),
            ),
          ),
          for (final entry in backgroundAnswers.indexed)
            Positioned(
              left: entry.$1.isEven ? 12 : null,
              right: entry.$1.isEven ? null : 8,
              top: 18.0 + entry.$1 * 62,
              width: 180,
              child: Transform.rotate(
                angle: entry.$1.isEven ? -0.13 : 0.10,
                child: Text(
                  entry.$2,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.CTextPrimary.withValues(alpha: 0.14),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TomatoMascot(
                    variant: TomatoMascotVariant.excited,
                    size: 112,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '당신의 마니또는',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    service.myManitto.displayName,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.CRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '입니다!',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChainView extends StatelessWidget {
  const _ChainView({required this.chain});

  final List<ManittoChainLink> chain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final link in chain) ...[
            Chip(
              label: Text(link.manitto.displayName),
              backgroundColor: AppColors.CSkyBlue.withValues(alpha: 0.35),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.CRed),
            Chip(
              label: Text(link.manitti.displayName),
              backgroundColor: AppColors.CPink.withValues(alpha: 0.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevealBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawHeart(
      canvas,
      Offset(size.width * 0.18, size.height * 0.22),
      AppColors.CPink.withValues(alpha: 0.22),
      18,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.82, size.height * 0.22),
      AppColors.CYellow.withValues(alpha: 0.38),
      20,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.24, size.height * 0.76),
      AppColors.CSkyBlue.withValues(alpha: 0.30),
      16,
    );
  }

  void _drawHeart(Canvas canvas, Offset center, Color color, double size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.45)
      ..cubicTo(
        center.dx - size,
        center.dy - size * 0.1,
        center.dx - size * 0.55,
        center.dy - size * 0.9,
        center.dx,
        center.dy - size * 0.35,
      )
      ..cubicTo(
        center.dx + size * 0.55,
        center.dy - size * 0.9,
        center.dx + size,
        center.dy - size * 0.1,
        center.dx,
        center.dy + size * 0.45,
      );
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, Color color, double size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.22, center.dy - size * 0.22)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx + size * 0.22, center.dy + size * 0.22)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.22, center.dy + size * 0.22)
      ..lineTo(center.dx - size, center.dy)
      ..lineTo(center.dx - size * 0.22, center.dy - size * 0.22)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
