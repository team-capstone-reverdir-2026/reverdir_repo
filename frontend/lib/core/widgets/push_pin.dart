import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 코르크 보드 핀 장식 (오늘의 질문 카드 상단).
enum PushPinColor { red, sky, yellow, green }

class PushPin extends StatelessWidget {
  const PushPin({
    super.key,
    this.color = PushPinColor.red,
    this.size = 28,
  });

  final PushPinColor color;
  final double size;

  Color get _pinColor => switch (color) {
        PushPinColor.red => AppColors.CRed,
        PushPinColor.sky => AppColors.CSkyBlue,
        PushPinColor.yellow => AppColors.CYellow,
        PushPinColor.green => AppColors.CGreen,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.4,
      child: CustomPaint(
        painter: _PushPinPainter(headColor: _pinColor),
      ),
    );
  }
}

class _PushPinPainter extends CustomPainter {
  _PushPinPainter({required this.headColor});

  final Color headColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final headRadius = size.width * 0.38;

    canvas.drawCircle(
      Offset(cx, headRadius),
      headRadius,
      Paint()
        ..color = headColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, headRadius),
      headRadius,
      Paint()
        ..color = AppColors.CTextPrimary.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final needle = Paint()
      ..color = AppColors.CTextSecondary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, headRadius * 2),
      Offset(cx, size.height),
      needle,
    );
  }

  @override
  bool shouldRepaint(covariant _PushPinPainter oldDelegate) =>
      oldDelegate.headColor != headColor;
}
