import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/doodle_background.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _repo = const AuthRepository();

  bool _isSubmitting = false;
  String? _apiError;
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: DoodleBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_apiError != null) _ApiErrorBanner(message: _apiError!),
                  CustomTextField(
                    controller: _nameController,
                    hint: '이름',
                    maxLength: 19,
                    errorText: _validationError,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _idController,
                    hint: '아이디',
                    maxLength: 19,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _pwController,
                    hint: '비밀번호',
                    obscureText: true,
                    maxLength: 19,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: '회원가입 완료',
                    onPressed: _submit,
                    isLoading: _isSubmitting,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final v = _validate();
    if (v != null) {
      setState(() => _validationError = v);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _apiError = null;
      _validationError = null;
    });

    try {
      final result = await _repo.register(
        name: _nameController.text.trim(),
        username: _idController.text.trim(),
        password: _pwController.text,
      );
      await SecureStorageService.instance.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.authRegister,
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: AppTextStyles.errorMessage)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validate() {
    final name = _nameController.text.trim();
    final username = _idController.text.trim();
    final password = _pwController.text;
    if (name.isEmpty || name.length >= 20) return '이름은 1~19자여야 해요.';
    if (username.length < 4 || username.length >= 20) {
      return '아이디는 4~19자여야 해요.';
    }
    if (password.length < 4 || password.length >= 20) {
      return '비밀번호는 4~19자여야 해요.';
    }
    return null;
  }
}

class _ApiErrorBanner extends StatelessWidget {
  const _ApiErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.CRed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.CTextPrimary),
      ),
    );
  }
}
