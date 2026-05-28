import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/doodle_background.dart';
import '../core/widgets/tomato_mascot.dart';
import 'manitto_game/data/mock_game_service.dart';

class DemoSetScreen extends StatelessWidget {
  const DemoSetScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final service = MockGameService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('데모 관리')),
      body: DoodleBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.CIvory,
                  borderRadius: AppTheme.borderRadius,
                  border: AppTheme.handDrawnBorder(color: AppColors.CRed),
                ),
                child: Column(
                  children: [
                    const TomatoMascot(
                      variant: TomatoMascotVariant.scribbling,
                      size: 96,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '체험용 시뮬레이터',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '결과 리포트를 바로 보고 싶다면 게임을 강제로 종료할 수 있어요.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                label: '게임 종료하기',
                onPressed: () {
                  service.finishGame();
                  context.go(AppRoutes.roomDetailPath(roomId));
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
