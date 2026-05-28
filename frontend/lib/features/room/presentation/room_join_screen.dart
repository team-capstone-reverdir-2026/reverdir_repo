import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/doodle_background.dart';

class RoomJoinScreen extends StatefulWidget {
  const RoomJoinScreen({
    super.key,
    required this.roomId,
    required this.invitationCode,
    required this.missionCount,
  });

  final String roomId;
  final String invitationCode;
  final int missionCount;

  @override
  State<RoomJoinScreen> createState() => _RoomJoinScreenState();
}

class _RoomJoinScreenState extends State<RoomJoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        ApiEndpoints.roomParticipants(widget.roomId),
        data: {'displayName': userName},
      );

      if (!mounted) return;
      context.push(
        AppRoutes.roomJoinMissionsPath(
          roomId: widget.roomId,
          missionCount: widget.missionCount,
          userName: userName,
        ),
      );
    } on ApiException catch (e, s) {
      if (e.code == ErrorCode.alreadyJoined) {
        if (!mounted) return;
        context.push(
          AppRoutes.roomJoinMissionsPath(
            roomId: widget.roomId,
            missionCount: widget.missionCount,
            userName: userName,
          ),
        );
        return;
      }
      developer.log(
        '참여자 등록 실패',
        name: 'ReverdirApi',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, s) {
      developer.log(
        '참여자 등록 실패',
        name: 'ReverdirApi',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입장에 실패했습니다. 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      appBar: AppBar(title: const Text('방 입장')),
      body: DoodleBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.CSkyBlue.withValues(alpha: 0.22),
                    borderRadius: AppTheme.borderRadius,
                    border: AppTheme.handDrawnBorder(color: AppColors.CSkyBlue),
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
                      CustomTextField(
                        controller: _nameController,
                        hint: '방에서 사용할 이름을 입력해 주세요',
                        maxLength: 20,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _goNext(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: '이전',
                        onPressed: _submitting ? null : () => context.pop(),
                        variant: CustomButtonVariant.outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        label: _submitting ? '입장 중...' : '다음',
                        onPressed: _submitting ? null : _goNext,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
