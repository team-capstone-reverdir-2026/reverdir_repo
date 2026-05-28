import 'package:flutter/material.dart';
import 'package:reverdir/core/debug/agent_debug_log.dart';
import 'package:reverdir/core/network/dio_client.dart';
import 'package:reverdir/core/router/app_router.dart';
import 'package:reverdir/core/storage/secure_storage_service.dart';
import 'package:reverdir/core/theme/app_colors.dart';
import 'package:reverdir/core/theme/app_theme.dart';
import 'package:reverdir/core/widgets/doodle_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.instance.init(
    tokenProvider: SecureStorageService.instance,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.light,
      builder: (context, child) {
        // #region agent log
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AgentDebugLog.log(
            location: 'main.dart:builder',
            message: 'App builder post-frame',
            hypothesisId: 'H2,H3',
            data: {
              'navigatorCanPop': Navigator.canPop(context),
              'childIsNull': child == null,
            },
          );
        });
        // #endregion

        return Stack(
          fit: StackFit.expand,
          children: [
            const IgnorePointer(
              child: ColoredBox(color: AppColors.CBackground),
            ),
            const DoodlePaintLayer(opacity: 0.36),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: DoodleBackground(
                  child: ColoredBox(
                    color: AppColors.CBackground,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
