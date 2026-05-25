import 'package:flutter/material.dart';

/// TomatoMascot.tsx variant 대응
enum TomatoMascotVariant {
  normal,
  sleepy,
  excited,
  peeking,
  scribbling,
  embarrassed,
}

/// 또마니또 토마토 마스코트 — 손그림 SVG Path 기반 [CustomPainter].
class TomatoMascot extends StatelessWidget {
  const TomatoMascot({
    super.key,
    this.variant = TomatoMascotVariant.normal,
    this.size = 48,
  });

  final TomatoMascotVariant variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TomatoMascotPainter(variant: variant),
      ),
    );
  }
}

class TomatoMascotPainter extends CustomPainter {
  TomatoMascotPainter({required this.variant});

  final TomatoMascotVariant variant;

  static const Color _body = Color(0xFFE84B3C);
  static const Color _leaf = Color(0xFF7BBF6A);
  static const Color _ink = Color(0xFF2A2620);
  static const Color _blush = Color(0xFFF08A4B);
  static const Color _spark = Color(0xFFF5C443);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(10, 10);

    _drawBody(canvas);
    _drawLeaves(canvas);
    _drawFace(canvas);

    canvas.restore();
  }

  void _drawBody(Canvas canvas) {
    final path = Path()
      ..moveTo(10, 50)
      ..cubicTo(5, 30, 15, 10, 40, 5)
      ..cubicTo(65, 0, 85, 15, 90, 40)
      ..cubicTo(95, 65, 80, 90, 50, 95)
      ..cubicTo(20, 100, 15, 70, 10, 50)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _body
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawLeaves(Canvas canvas) {
    final path = Path()
      ..moveTo(50, 15)
      ..cubicTo(40, 5, 30, 10, 25, 20)
      ..cubicTo(35, 20, 45, 15, 50, 15)
      ..moveTo(50, 15)
      ..cubicTo(60, 5, 75, 5, 80, 15)
      ..cubicTo(70, 20, 60, 18, 50, 15)
      ..moveTo(50, 15)
      ..cubicTo(50, 0, 55, -5, 55, -10)
      ..cubicTo(50, -5, 45, 0, 50, 15);

    canvas.drawPath(
      path,
      Paint()
        ..color = _leaf
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawFace(Canvas canvas) {
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = _ink
      ..style = PaintingStyle.fill;

    switch (variant) {
      case TomatoMascotVariant.sleepy:
        canvas.drawPath(Path()..moveTo(30, 45)..quadraticBezierTo(35, 40, 40, 45), stroke);
        canvas.drawPath(Path()..moveTo(60, 45)..quadraticBezierTo(65, 40, 70, 45), stroke);
        canvas.drawPath(Path()..moveTo(45, 60)..quadraticBezierTo(50, 65, 55, 60), stroke);
        canvas.drawCircle(const Offset(78, 28), 2, fill);
        canvas.drawCircle(const Offset(88, 18), 1.5, fill);
      case TomatoMascotVariant.excited:
        canvas.drawPath(Path()..moveTo(30, 40)..lineTo(40, 35)..lineTo(45, 45), stroke);
        canvas.drawPath(Path()..moveTo(70, 40)..lineTo(60, 35)..lineTo(55, 45), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(40, 60)
            ..cubicTo(45, 75, 55, 75, 60, 60)
            ..close(),
          fill,
        );
        final spark = Paint()
          ..color = _spark
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(20, 30), const Offset(15, 20), spark);
        canvas.drawLine(const Offset(80, 30), const Offset(85, 20), spark);
        canvas.drawLine(const Offset(50, 10), const Offset(50, 0), spark);
      case TomatoMascotVariant.peeking:
        canvas.drawCircle(const Offset(35, 35), 4, fill);
        canvas.drawCircle(const Offset(65, 35), 4, fill);
        canvas.drawPath(Path()..moveTo(45, 50)..quadraticBezierTo(50, 45, 55, 50), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(20, 70)
            ..cubicTo(15, 60, 25, 55, 30, 65)
            ..close(),
          Paint()..color = _body,
        );
        canvas.drawPath(
          Path()
            ..moveTo(80, 70)
            ..cubicTo(85, 60, 75, 55, 70, 65)
            ..close(),
          Paint()..color = _body,
        );
      case TomatoMascotVariant.embarrassed:
        canvas.drawCircle(const Offset(35, 45), 3, fill);
        canvas.drawCircle(const Offset(65, 45), 3, fill);
        canvas.drawPath(Path()..moveTo(45, 65)..quadraticBezierTo(50, 60, 55, 65), stroke);
        final blush = Paint()
          ..color = _blush
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(20, 55), const Offset(30, 50), blush);
        canvas.drawLine(const Offset(25, 60), const Offset(35, 55), blush);
        canvas.drawLine(const Offset(70, 50), const Offset(80, 55), blush);
        canvas.drawLine(const Offset(65, 55), const Offset(75, 60), blush);
      case TomatoMascotVariant.scribbling:
        canvas.drawCircle(const Offset(35, 45), 3, fill);
        canvas.drawCircle(const Offset(65, 45), 3, fill);
        canvas.drawPath(Path()..moveTo(45, 60)..quadraticBezierTo(50, 65, 55, 60), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(70, 60)
            ..lineTo(90, 80)
            ..lineTo(85, 85)
            ..lineTo(65, 65)
            ..close(),
          Paint()..color = _spark,
        );
        canvas.drawPath(
          Path()
            ..moveTo(90, 80)
            ..lineTo(95, 85)
            ..lineTo(85, 85)
            ..close(),
          fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(95, 85)
            ..cubicTo(100, 90, 110, 85, 115, 95),
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case TomatoMascotVariant.normal:
        canvas.drawCircle(const Offset(35, 45), 3, fill);
        canvas.drawCircle(const Offset(65, 45), 3, fill);
        canvas.drawPath(
          Path()
            ..moveTo(40, 60)
            ..cubicTo(45, 65, 55, 65, 60, 60),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant TomatoMascotPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
