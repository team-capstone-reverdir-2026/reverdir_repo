import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';

/// 앱 내 뒤로가기 (브라우저 히스토리 대신 사용).
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.fallbackToHome = false,
  });

  final VoidCallback? onPressed;
  final bool fallbackToHome;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.CIvory.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              } else if (fallbackToHome) {
                context.go(AppRoutes.home);
              }
            },
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.CTextPrimary,
          ),
        ),
      ),
    );
  }
}

/// 화면 좌상단에 뒤로가기 버튼을 올립니다.
class AppBackButtonOverlay extends StatelessWidget {
  const AppBackButtonOverlay({
    super.key,
    this.onPressed,
    this.fallbackToHome = false,
    this.top = 8,
    this.left = 8,
  });

  final VoidCallback? onPressed;
  final bool fallbackToHome;
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: AppBackButton(
        onPressed: onPressed,
        fallbackToHome: fallbackToHome,
      ),
    );
  }
}
