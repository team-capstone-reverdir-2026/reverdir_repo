import 'package:flutter/material.dart';
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
        return DoodleBackground(
          opacity: 0.22,
          child: ColoredBox(
            color: AppColors.CBackground,
            child: Center(
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
          ),
        );
      },
    );
  }
}
