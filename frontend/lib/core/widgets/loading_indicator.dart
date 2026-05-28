import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// API·페이지 로딩용 아기자기한 스피너.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
    this.color,
  });

  final double size;
  final double strokeWidth;

  /// 기본 [AppColors.COrange] — 진행·폴링 무드
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.COrange,
        ),
      ),
    );
  }
}

/// CTA 버튼 내부 등 작은 로딩 (토마토 레드)
class LoadingIndicatorSmall extends StatelessWidget {
  const LoadingIndicatorSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingIndicator(
      size: 22,
      strokeWidth: 2.5,
      color: AppColors.CBackground,
    );
  }
}
