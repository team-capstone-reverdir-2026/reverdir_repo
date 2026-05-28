import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/washi_tape.dart';

class MissionInputScreen extends StatefulWidget {
  const MissionInputScreen({
    super.key,
    required this.invitationCode,
    required this.missionCount,
    required this.userName,
  });

  final String invitationCode;
  final int missionCount;
  final String userName;

  @override
  State<MissionInputScreen> createState() => _MissionInputScreenState();
}

class _MissionInputScreenState extends State<MissionInputScreen> {
  late final List<TextEditingController> _controllers;
  bool _submitting = false;

  String _apiPath(String endpointPath) => '/api/v1$endpointPath';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.missionCount,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _fetchRecommendedMission(int index) async {
    try {
      final res =
          await apiClient.get<Map<String, dynamic>>(ApiEndpoints.missionsRandom);
      final content = (res.data?['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) return;
      _controllers[index].text = content;
      _controllers[index].selection =
          TextSelection.collapsed(offset: content.length);
      if (!mounted) return;
      setState(() {});
    } catch (e, s) {
      _showApiError(
        method: 'GET',
        url: _apiPath(ApiEndpoints.missionsRandom),
        error: e,
        stackTrace: s,
      );
    }
  }

  void _clearMissionField(int index) {
    _controllers[index].clear();
    setState(() {});
  }

  Future<void> _submitFinalJoin() async {
    final missions = _controllers
        .map((c) => c.text.trim())
        .where((m) => m.isNotEmpty)
        .toList(growable: false);

    if (missions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션을 최소 1개 이상 입력해 주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);

    Future<T?> guardCall<T>({
      required String method,
      required String url,
      required Future<T> Function() call,
    }) async {
      try {
        return await call();
      } catch (e, s) {
        _showApiError(method: method, url: url, error: e, stackTrace: s);
        return null;
      }
    }

    try {
      // 1) invitationCode로 roomId 확보
      final joinPreview = await guardCall(
        method: 'POST',
        url: _apiPath(ApiEndpoints.roomsJoin),
        call: () => apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.roomsJoin,
          data: {'inviteCode': widget.invitationCode},
        ),
      );
      if (joinPreview == null) return;
      final roomId = (joinPreview.data?['roomId'] as String?)?.trim() ?? '';
      if (roomId.isEmpty) {
        throw Exception('roomId is empty');
      }

      // 2) 사용자 방 입장 등록 (displayName)
      final participantRes = await guardCall(
        method: 'POST',
        url: _apiPath(ApiEndpoints.roomParticipants(roomId)),
        call: () => apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.roomParticipants(roomId),
          data: {'displayName': widget.userName},
        ),
      );
      if (participantRes == null) return;

      // 3) 미션 업로드
      for (final mission in missions) {
        final missionRes = await guardCall(
          method: 'POST',
          url: _apiPath(ApiEndpoints.roomMissions(roomId)),
          call: () => apiClient.post<Map<String, dynamic>>(
            ApiEndpoints.roomMissions(roomId),
            data: {'content': mission},
          ),
        );
        if (missionRes == null) return;
      }

      // 4) 현재 게임 상태 조회 후 상태별 라우팅
      final roomDetailRes = await guardCall(
        method: 'GET',
        url: _apiPath(ApiEndpoints.room(roomId)),
        call: () => apiClient.get<Map<String, dynamic>>(ApiEndpoints.room(roomId)),
      );
      if (roomDetailRes == null || !mounted) return;
      final status = (roomDetailRes.data?['status'] as String?)?.trim();
      if (status == 'ENDED') {
        context.go(AppRoutes.roomResultsPath(roomId));
      } else {
        // BEFORE_START/WAITING/IN_PROGRESS -> 게임 메인(내부에서 phase 분기)
        context.go(AppRoutes.roomDetailPath(roomId));
      }
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.rotate(
                angle: 1.0 * math.pi / 180,
                child: Hero(
                  tag: 'notebook_container',
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.CPink.withValues(alpha: 0.26),
                                AppColors.CSkyBlue.withValues(alpha: 0.2),
                                AppColors.CIvory,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: AppTheme.handDrawnBorder(color: AppColors.CBrown),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('미션 입력', style: AppTextStyles.titleLarge),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.userName}님, 미션 ${widget.missionCount}개를 입력해 주세요.',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(_controllers.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _controllers[index],
                                          maxLength: 200,
                                          minLines: 1,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor:
                                                AppColors.CBackground.withValues(alpha: 0.92),
                                            hintText: '미션 ${index + 1} 입력',
                                            hintStyle: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.CTextTertiary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: AppTheme.handDrawnBorderSide(
                                                color: AppColors.CBrown.withValues(alpha: 0.7),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: AppTheme.handDrawnBorderSide(
                                                color: AppColors.CBrown.withValues(alpha: 0.7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: AppTheme.handDrawnBorderSide(
                                                color: AppColors.COrange,
                                                width: 1.8,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              tooltip: '해당 미션 지우기',
                                              onPressed: () => _clearMissionField(index),
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                color: AppColors.CTextTertiary,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: '추천 미션',
                                        onPressed: () => _fetchRecommendedMission(index),
                                        icon: const Icon(Icons.refresh_rounded),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: 12,
                          child: WashiTape.horizontal(
                            color: WashiTapeColor.pink,
                            width: 78,
                            rotation: 8,
                          ),
                        ),
                      ],
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
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      variant: CustomButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: _submitting ? '입장 중...' : '다음',
                      onPressed: _submitting ? null : _submitFinalJoin,
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
