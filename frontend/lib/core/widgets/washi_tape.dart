import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 와시 테이프 색상 — WashiTape.tsx color prop 대응
enum WashiTapeColor {
  yellow,
  blue,
  pink,
  green,
  orange,
}

/// 와시 테이프(마스킹 테이프) — 삐뚤한 각도·거친 단면·스트라이프 질감.
///
/// ```dart
/// Positioned(
///   top: -8, // 장식 돌출은 margin 대신 Stack + Positioned로만 처리
///   left: 24,
///   child: WashiTape(
///     color: WashiTapeColor.yellow,
///     width: 96,
///     rotation: -2,
///   ),
/// )
/// ```
class WashiTape extends StatelessWidget {
  const WashiTape({
    super.key,
    this.color = WashiTapeColor.yellow,
    this.width = 96,
    this.height = 24,
    this.rotation = -2,
    this.classNameOffset,
  });

  /// [WashiTape.tsx] color prop
  final WashiTapeColor color;
  final double width;
  final double height;
  final double rotation;
  final Offset? classNameOffset;

  Color get _tapeColor => switch (color) {
        WashiTapeColor.yellow => AppColors.CYellow.withValues(alpha: 0.7),
        WashiTapeColor.blue => AppColors.CSkyBlue.withValues(alpha: 0.7),
        WashiTapeColor.pink => AppColors.CRed.withValues(alpha: 0.5),
        WashiTapeColor.green => AppColors.CGreen.withValues(alpha: 0.6),
        WashiTapeColor.orange => AppColors.COrange.withValues(alpha: 0.6),
      };

  /// 가로 테이프 (카드 상단)
  factory WashiTape.horizontal({
    Key? key,
    WashiTapeColor color = WashiTapeColor.yellow,
    double width = 96,
    double rotation = -2,
  }) {
    return WashiTape(
      key: key,
      color: color,
      width: width,
      height: 24,
      rotation: rotation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: classNameOffset ?? Offset.zero,
      child: Transform.rotate(
        angle: rotation * math.pi / 180,
        child: ClipPath(
          clipper: _WashiTapeClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: _tapeColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.CTextPrimary.withValues(alpha: 0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _WashiStripePainter(),
                size: Size(width, height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// React clipPath polygon 대응 — 거친 테이프 단면
class _WashiTapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h * 0.05)
      ..lineTo(w * 0.05, 0)
      ..lineTo(w * 0.95, h * 0.05)
      ..lineTo(w, h * 0.1)
      ..lineTo(w * 0.95, h * 0.95)
      ..lineTo(w, h)
      ..lineTo(w * 0.05, h * 0.95)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// subtle stripe texture (linear-gradient 4px)
class _WashiStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.45, 0.5, 0.55],
        tileMode: TileMode.repeated,
      ).createShader(Rect.fromLTWH(0, 0, 4, size.height))
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..color = Colors.white.withValues(alpha: 0.2),
    );

    for (var x = 0.0; x < size.width; x += 4) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// API·화면별 추천 와시 색
abstract final class WashiPresets {
  WashiPresets._();

  static const roomWaiting = WashiTapeColor.yellow;
  static const roomInProgress = WashiTapeColor.orange;
  static const noteSent = WashiTapeColor.pink;
  static const noteReceived = WashiTapeColor.blue;
  static const missionComplete = WashiTapeColor.green;
}
