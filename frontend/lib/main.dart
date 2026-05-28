import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(const ManittoApp());
}

class ManittoApp extends StatelessWidget {
  const ManittoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '또마니또',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}