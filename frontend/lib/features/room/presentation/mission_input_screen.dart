import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../../core/widgets/washi_tape.dart';

class MissionInputScreen extends StatefulWidget {
  const MissionInputScreen({
    super.key,
    required this.roomId,
    required this.missionCount,
    required this.userName,
  });

  final String roomId;
  final int missionCount;
  final String userName;

  @override
  State<MissionInputScreen> createState() => _MissionInputScreenState();
}

class _MissionInputScreenState extends State<MissionInputScreen> {
  late final List<TextEditingController> _controllers;
  bool _submitting = false;

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
      developer.log('추천 미션 조회 실패', name: 'ReverdirApi', error: e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천 미션을 불러오지 못했어요.')),
      );
    }
  }

  void _clearMissionField(int index) {
    _controllers[index].clear();
    setState(() {});
  }

  Future<void> _submitMissions() async {
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

    if (widget.roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 정보가 없습니다. 처음부터 다시 입장해 주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      for (final mission in missions) {
        await apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.roomMissions(widget.roomId),
          data: {'content': mission},
        );
      }

      final roomDetailRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.room(widget.roomId),
      );
      if (!mounted) return;
      final status = (roomDetailRes.data?['status'] as String?)?.trim();
      if (status == 'ENDED') {
        context.go(AppRoutes.roomResultsPath(widget.roomId));
      } else {
        final encodedName = Uri.encodeComponent(widget.userName);
        context.go(
          '${AppRoutes.roomDetailPath(widget.roomId)}'
          '?displayName=$encodedName&r=${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } on ApiException catch (e, s) {
      developer.log('미션 등록 실패', name: 'ReverdirApi', error: e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, s) {
      developer.log('미션 등록 실패', name: 'ReverdirApi', error: e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션 등록에 실패했습니다. 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      appBar: AppBar(title: const Text('미션 입력')),
      body: DoodleBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.CPink.withValues(alpha: 0.22),
                        borderRadius: AppTheme.borderRadius,
                        border: AppTheme.handDrawnBorder(color: AppColors.CPink),
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
                                      style: AppTextStyles.input,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.CBackground
                                            .withValues(alpha: 0.92),
                                        hintText: '미션 ${index + 1} 입력',
                                        hintStyle: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: AppColors.CTextTertiary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide:
                                              AppTheme.handDrawnBorderSide(
                                            color: AppColors.CBrown
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide:
                                              AppTheme.handDrawnBorderSide(
                                            color: AppColors.CBrown
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide:
                                              AppTheme.handDrawnBorderSide(
                                            color: AppColors.COrange,
                                            width: 1.8,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: '해당 미션 지우기',
                                          onPressed: () =>
                                              _clearMissionField(index),
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
                                    onPressed: () =>
                                        _fetchRecommendedMission(index),
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
                        label: _submitting ? '입장 중...' : '입장 완료',
                        onPressed: _submitting ? null : _submitMissions,
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
