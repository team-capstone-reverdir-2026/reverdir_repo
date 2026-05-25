import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 손으로 그린 듯한 배경 낙서 레이어.
///
/// 화면의 기능 영역을 방해하지 않도록 낮은 opacity로 깔아 씁니다.
class DoodleBackground extends StatelessWidget {
  const DoodleBackground({
    super.key,
    required this.child,
    this.opacity = 0.34,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DoodlePainter(opacity: opacity),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final doodles = [
      _DoodleSpec(_DoodleKind.sparkle, const Offset(0.10, 0.12),
          AppColors.CYellow, 18, -0.2),
      _DoodleSpec(_DoodleKind.heart, const Offset(0.82, 0.10), AppColors.CPink,
          20, 0.2),
      _DoodleSpec(_DoodleKind.star, const Offset(0.18, 0.32),
          AppColors.CSkyBlue, 16, 0.4),
      _DoodleSpec(_DoodleKind.sparkle, const Offset(0.88, 0.34),
          AppColors.COrange, 16, -0.5),
      _DoodleSpec(_DoodleKind.heart, const Offset(0.08, 0.62), AppColors.CRed,
          16, -0.4),
      _DoodleSpec(_DoodleKind.star, const Offset(0.86, 0.70), AppColors.CGreen,
          18, 0.1),
      _DoodleSpec(_DoodleKind.sparkle, const Offset(0.45, 0.86),
          AppColors.CPurple, 20, 0.3),
    ];

    for (final doodle in doodles) {
      canvas.save();
      canvas.translate(
          size.width * doodle.position.dx, size.height * doodle.position.dy);
      canvas.rotate(doodle.rotation);
      final paint = Paint()
        ..color = doodle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      switch (doodle.kind) {
        case _DoodleKind.sparkle:
          _drawSparkle(canvas, paint, doodle.size);
        case _DoodleKind.heart:
          _drawHeart(canvas, paint, doodle.size);
        case _DoodleKind.star:
          _drawStar(canvas, paint, doodle.size);
      }

      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, double size) {
    canvas.drawLine(Offset(0, -size), Offset(0, size), paint);
    canvas.drawLine(Offset(-size, 0), Offset(size, 0), paint);
    canvas.drawLine(Offset(-size * 0.55, -size * 0.55),
        Offset(size * 0.55, size * 0.55), paint);
    canvas.drawLine(Offset(size * 0.55, -size * 0.55),
        Offset(-size * 0.55, size * 0.55), paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double size) {
    final path = Path()
      ..moveTo(0, size * 0.75)
      ..cubicTo(-size * 1.1, 0, -size * 0.55, -size * 0.85, 0, -size * 0.25)
      ..cubicTo(size * 0.55, -size * 0.85, size * 1.1, 0, 0, size * 0.75);
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.26, -size * 0.28)
      ..lineTo(size, -size * 0.25)
      ..lineTo(size * 0.42, size * 0.18)
      ..lineTo(size * 0.62, size)
      ..lineTo(0, size * 0.52)
      ..lineTo(-size * 0.62, size)
      ..lineTo(-size * 0.42, size * 0.18)
      ..lineTo(-size, -size * 0.25)
      ..lineTo(-size * 0.26, -size * 0.28)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _DoodleSpec {
  const _DoodleSpec(
    this.kind,
    this.position,
    this.color,
    this.size,
    this.rotation,
  );

  final _DoodleKind kind;
  final Offset position;
  final Color color;
  final double size;
  final double rotation;
}

enum _DoodleKind { sparkle, heart, star }
