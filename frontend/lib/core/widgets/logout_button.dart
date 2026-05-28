import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../router/app_routes.dart';
import '../storage/secure_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key, this.compact = true});

  final bool compact;

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _loading = false;

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await apiClient.post<Map<String, dynamic>>(ApiEndpoints.authLogout);
      await SecureStorageService.instance.deleteAllTokens();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: _loading ? null : _logout,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.CIvory.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.CBrown.withValues(alpha: 0.7),
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _loading ? Icons.hourglass_top_rounded : Icons.logout_rounded,
                  size: 14,
                  color: AppColors.CTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _loading ? '처리중' : '로그아웃',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.CTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _loading ? null : _logout,
      icon: Icon(_loading ? Icons.hourglass_top_rounded : Icons.logout_rounded),
      tooltip: '로그아웃',
    );
  }
}
