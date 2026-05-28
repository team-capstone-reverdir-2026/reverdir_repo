import 'package:flutter/material.dart';
import 'package:reverdir/core/network/dio_client.dart';
import 'package:reverdir/core/router/app_router.dart';
import 'package:reverdir/core/storage/secure_storage_service.dart';
import 'package:reverdir/core/theme/app_theme.dart';

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
        return ColoredBox(
          color: AppTheme.light.scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ColoredBox(
                color: AppTheme.light.scaffoldBackgroundColor,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
