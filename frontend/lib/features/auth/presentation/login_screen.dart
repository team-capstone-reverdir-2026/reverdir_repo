import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/doodle_background.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _repo = const AuthRepository();
  bool _isSubmitting = false;
  String? _apiError;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text('또마니또 로그인', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 18),
                  if (_apiError != null) _ApiErrorBanner(message: _apiError!),
                  CustomTextField(
                    controller: _idController,
                    hint: '아이디',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _pwController,
                    hint: '비밀번호',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: '로그인',
                    onPressed: _submit,
                    isLoading: _isSubmitting,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: '계정이 없으신가요? 회원가입',
                    onPressed: () => context.push(AppRoutes.register),
                    variant: CustomButtonVariant.text,
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
    setState(() {
      _isSubmitting = true;
      _apiError = null;
    });

    try {
      final result = await _repo.login(
        username: _idController.text.trim(),
        password: _pwController.text,
      );
      await SecureStorageService.instance.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on ApiException catch (e, s) {
      final message = e.message.trim().isEmpty
          ? '로그인에 실패했습니다. 아이디/비밀번호를 확인해 주세요.'
          : e.message;
      ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.authLogin,
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: AppTextStyles.errorMessage)),
      );
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.authLogin,
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
