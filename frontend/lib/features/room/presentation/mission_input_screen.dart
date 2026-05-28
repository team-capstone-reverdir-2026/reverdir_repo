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

  Future<void> _openInlinePopup(int index) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                FocusScope.of(this.context).requestFocus(FocusNode());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete'),
              onTap: () {
                _controllers[index].clear();
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
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

      if (!mounted) return;
      context.go(AppRoutes.roomDetailPath(roomId));
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.CIvory.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.CBrown.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
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
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onLongPress: () => _openInlinePopup(index),
                                      child: TextField(
                                        controller: _controllers[index],
                                        maxLength: 200,
                                        decoration: InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: Colors.transparent,
                                          hintText: '미션 ${index + 1} 입력',
                                          hintStyle: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.CTextTertiary,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            borderSide: BorderSide(
                                              color: AppColors.CBrown
                                                  .withValues(alpha: 0.45),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            borderSide: BorderSide(
                                              color: AppColors.CBrown
                                                  .withValues(alpha: 0.45),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: AppColors.COrange,
                                              width: 1.8,
                                            ),
                                          ),
                                        ),
                                        onTap: () => _openInlinePopup(index),
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
