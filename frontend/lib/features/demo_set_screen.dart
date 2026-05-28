import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/extensions.dart';
import '../core/widgets/app_back_button.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/doodle_background.dart';
import '../core/widgets/tomato_mascot.dart';

class DemoSetScreen extends StatefulWidget {
  const DemoSetScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<DemoSetScreen> createState() => _DemoSetScreenState();
}

class _DemoSetScreenState extends State<DemoSetScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데모 관리'),
        leading: const AppBackButton(),
        automaticallyImplyLeading: false,
      ),
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
                label: _submitting ? '종료 중...' : '게임 종료하기',
                onPressed: _submitting
                    ? null
                    : () async {
                        try {
                          setState(() => _submitting = true);
                          await apiClient.post<Map<String, dynamic>>(
                            ApiEndpoints.roomGameEnd(widget.roomId),
                          );
                          if (!mounted) return;
                          context.go(AppRoutes.roomDetailPath(widget.roomId));
                        } catch (e) {
                          if (!mounted) return;
                          context.showUserError(e);
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
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
