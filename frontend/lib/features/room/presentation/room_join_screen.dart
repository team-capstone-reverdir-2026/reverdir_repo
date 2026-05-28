import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class RoomJoinScreen extends StatefulWidget {
  const RoomJoinScreen({
    super.key,
    required this.invitationCode,
    required this.missionCount,
  });

  final String invitationCode;
  final int missionCount;

  @override
  State<RoomJoinScreen> createState() => _RoomJoinScreenState();
}

class _RoomJoinScreenState extends State<RoomJoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;

  String _apiPath(String endpointPath) => '/api/v1$endpointPath';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showApiError({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final message = '[API 에러] $method $url 연결 실패 - 서버 상태를 확인하세요.';
    developer.log(
      message,
      name: 'ReverdirApi',
      error: error,
      stackTrace: stackTrace,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _goNext() async {
    final userName = _nameController.text.trim();
    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해 주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.roomsJoin,
        data: {'inviteCode': widget.invitationCode},
      );

      if (!mounted) return;
      context.push(
        AppRoutes.roomJoinMissionsPath(
          invitationCode: widget.invitationCode,
          missionCount: widget.missionCount,
          userName: Uri.encodeComponent(userName),
        ),
      );
    } catch (e, s) {
      _showApiError(
        method: 'POST',
        url: _apiPath(ApiEndpoints.roomsJoin),
        error: e,
        stackTrace: s,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.rotate(
                angle: -1.0 * math.pi / 180,
                child: Hero(
                  tag: 'notebook_container',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.CIvory.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.CBrown.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '당신은 누구십니까?',
                            style: AppTextStyles.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _nameController,
                            maxLength: 20,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: '방에서 사용할 이름을 입력해 주세요',
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.CTextTertiary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.CBrown.withValues(alpha: 0.45),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.CBrown.withValues(alpha: 0.45),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.COrange,
                                  width: 1.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: '이전',
                      onPressed: _submitting ? null : () => context.go(AppRoutes.home),
                      variant: CustomButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: _submitting ? '확인 중...' : '다음',
                      onPressed: _submitting ? null : _goNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
