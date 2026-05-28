import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/debug/agent_debug_log.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../hint/provider/hint_provider.dart';
import '../../room/data/room_invite_code_cache.dart';
import '../../mission/provider/mission_provider.dart';
import '../data/game_repository.dart';
import 'widgets/finished_view.dart';
import 'widgets/in_progress_view.dart';
import 'widgets/pre_start_view.dart';

enum GamePhase { preStart, inProgress, finished }

/// 방 메인 — GET /rooms/{roomId} (IN_PROGRESS)
///
/// 하단: 설정(데모) · 쪽지함 · 쪽지 쓰기
class GameMainScreen extends StatefulWidget {
  const GameMainScreen({
    super.key,
    required this.roomId,
    this.myDisplayName,
    this.inviteCodeQuery,
  });

  final String roomId;
  final String? myDisplayName;
  final String? inviteCodeQuery;

  @override
  State<GameMainScreen> createState() => _GameMainScreenState();
}

class _GameMainScreenState extends State<GameMainScreen> {
  final _repo = const GameRepository();
  bool _loading = true;
  String? _apiError;

  RoomDetailData? _detail;
  List<ParticipantData> _participants = const [];
  List<EditableMission> _draftMissions = const [];
  late final MissionProvider _missionProvider;
  int _maxMissionCount = 0;
  TodayQuestionViewData? _todayQuestion;
  String? _myManittiName;
  String _resolvedInviteCode = '';

  @override
  void initState() {
    super.initState();
    _missionProvider = MissionProvider(
      const [],
      onToggleRemote: (missionId, isCompleted) => _repo.patchMission(
        widget.roomId,
        missionId,
        isCompleted: isCompleted,
      ),
    );
    _load();
  }

  @override
  void dispose() {
    _missionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // #region agent log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      AgentDebugLog.log(
        location: 'game_main_screen.dart:build',
        message: 'GameMainScreen post-frame state',
        hypothesisId: 'H1,H2,H4,H5',
        data: {
          'loading': _loading,
          'apiError': _apiError,
          'detailIsNull': _detail == null,
          'detailStatus': _detail?.status.name,
          'hasTodayQuestion': _todayQuestion != null,
          'navigatorCanPop': Navigator.canPop(context),
          'routeBarrierColor': route?.barrierColor?.toString(),
          'routeIsCurrent': route?.isCurrent,
          'roomId': widget.roomId,
        },
      );
    });
    // #endregion

    return Scaffold(
      backgroundColor: AppColors.CBackground,
      body: DoodleBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _apiError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(_apiError!, style: AppTextStyles.bodyMedium),
                    ),
                  )
                : Stack(
                    children: [
                      _buildBody(),
                      SafeArea(
                        child: AppBackButtonOverlay(
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ),
                      if ((_detail?.status ?? RoomStatus.waiting) ==
                          RoomStatus.inProgress)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _GameBottomBar(roomId: widget.roomId),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildBody() {
    final detail = _detail;
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final phase = switch (detail.status) {
      RoomStatus.waiting => GamePhase.preStart,
      RoomStatus.inProgress => GamePhase.inProgress,
      RoomStatus.ended => GamePhase.finished,
    };
    // #region agent log
    if (phase == GamePhase.preStart) {
      AgentDebugLog.log(
        location: 'game_main_screen.dart:_buildBody',
        message: 'preStart phase data types',
        hypothesisId: 'H12,H19',
        data: {
          'participantsLen': _participants.length,
          'draftMissionsLen': _draftMissions.length,
          'participantsListType': _participants.runtimeType.toString(),
          'draftMissionsListType': _draftMissions.runtimeType.toString(),
          'isHost': detail.isHost,
          'isHostType': detail.isHost.runtimeType.toString(),
        },
      );
    }
    // #endregion
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (phase) {
        GamePhase.preStart => PreStartView(
            key: ValueKey('preStart_${_draftMissions.length}_$_maxMissionCount'),
            roomName: detail.name,
            roomDescription: detail.description,
            inviteCode: _resolvedInviteCode,
            maxMissionCount: _maxMissionCount,
            isHost: detail.isHost,
            participants: _participants,
            myMissionCount: _draftMissions.length,
            myDisplayName: widget.myDisplayName,
            myMissions: _draftMissions,
            onStart: _startGame,
            onAddMission: _addMission,
            onRecommend: _repo.recommendMission,
            onUpdateMission: _updateMission,
            onDeleteMission: _deleteMission,
          ),
        GamePhase.inProgress => _todayQuestion == null
            ? _InProgressFallback(
                key: const ValueKey('inProgress_missing_question'),
                onRetry: _load,
              )
            : InProgressView(
            key: const ValueKey(GamePhase.inProgress),
            roomId: widget.roomId,
            roomName: detail.name,
            status: detail.status,
            daysRemaining: detail.daysRemaining,
            participantNames:
                _participants.map((e) => e.displayName).toList(growable: false),
            todayQuestion: _todayQuestion!,
            missionProvider: _missionProvider,
            onAnswerSubmitted: _submitTodayAnswer,
            myManittiDisplayName: _myManittiName,
            endsAt: detail.endsAt,
          ),
        GamePhase.finished => FinishedView(
            key: const ValueKey(GamePhase.finished),
            participantCount: detail.participantCount,
            receivedNoteCount: 0,
            onOpenLetters: () =>
                context.push(AppRoutes.roomNotesPath(widget.roomId)),
            onOpenResults: () =>
                context.push(AppRoutes.roomResultsPath(widget.roomId)),
          ),
      },
    );
  }

  Future<void> _load() async {
    // #region agent log
    AgentDebugLog.log(
      location: 'game_main_screen.dart:_load',
      message: '_load started',
      hypothesisId: 'H1',
      data: {'roomId': widget.roomId},
    );
    // #endregion

    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final detail = await _repo.fetchRoomDetail(widget.roomId);
      final participants = await _repo.fetchParticipants(widget.roomId);
      final missionData = await _repo.fetchMissions(widget.roomId);

      TodayQuestionViewData? question;
      String? myManitti;

      if (detail.status == RoomStatus.inProgress) {
        question = await _repo.fetchTodayQuestion(widget.roomId);
        try {
          myManitti = await _repo.fetchMyManittiName(widget.roomId);
        } catch (_) {}
      }

      final maxCount = missionData.maxCount > 0
          ? missionData.maxCount
          : detail.missionCount;

      final inviteCode = RoomInviteCodeCache.resolve(
        roomId: widget.roomId,
        fromApi: detail.inviteCode,
        fromQuery: widget.inviteCodeQuery,
      );
      if (inviteCode.isNotEmpty) {
        RoomInviteCodeCache.save(widget.roomId, inviteCode);
      }

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _participants = participants;
        _maxMissionCount = maxCount;
        _draftMissions = missionData.missions
            .map<EditableMission>(
              (m) => EditableMission(id: m.id, content: m.content),
            )
            .toList(growable: false);
        _todayQuestion = question;
        _myManittiName = myManitti;
        _resolvedInviteCode = inviteCode;
        _missionProvider.setMissions(missionData.missions);
      });
      // #region agent log
      AgentDebugLog.log(
        location: 'game_main_screen.dart:_load',
        message: '_load success',
        hypothesisId: 'H1,H4',
        data: {
          'status': detail.status.name,
          'hasTodayQuestion': question != null,
          'participantCount': participants.length,
        },
      );
      // #endregion
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'GET',
        url: ApiEndpoints.room(widget.roomId),
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      // #region agent log
      AgentDebugLog.log(
        location: 'game_main_screen.dart:_load',
        message: '_load failed',
        hypothesisId: 'H1,H5,H6',
        data: {
          'error': message,
          'exceptionType': e.runtimeType.toString(),
        },
      );
      // #endregion
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        // #region agent log
        AgentDebugLog.log(
          location: 'game_main_screen.dart:_load',
          message: '_load finally',
          hypothesisId: 'H1,H5',
          data: {
            'loading': false,
            'detailIsNull': _detail == null,
            'apiError': _apiError,
          },
        );
        // #endregion
      }
    }
  }

  Future<void> _startGame() async {
    await _repo.startGame(widget.roomId);
    await _load();
  }

  Future<void> _addMission(String content) async {
    await _repo.addMission(widget.roomId, content);
    await _refreshMissionsOnly();
  }

  Future<void> _updateMission(String missionId, String content) async {
    await _repo.patchMission(widget.roomId, missionId, content: content);
    await _refreshMissionsOnly();
  }

  Future<void> _deleteMission(String missionId) async {
    await _repo.deleteMission(widget.roomId, missionId);
    await _refreshMissionsOnly();
  }

  Future<void> _refreshMissionsOnly() async {
    try {
      final participants = await _repo.fetchParticipants(widget.roomId);
      final missionData = await _repo.fetchMissions(widget.roomId);
      final maxCount = missionData.maxCount > 0
          ? missionData.maxCount
          : (_detail?.missionCount ?? _maxMissionCount);

      if (!mounted) return;
      setState(() {
        _participants = participants;
        _maxMissionCount = maxCount;
        _draftMissions = missionData.missions
            .map<EditableMission>(
              (m) => EditableMission(id: m.id, content: m.content),
            )
            .toList(growable: false);
        _missionProvider.setMissions(missionData.missions);
      });
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'GET',
        url: ApiEndpoints.roomMissions(widget.roomId),
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      context.showSnackBar(message);
    }
  }

  Future<void> _submitTodayAnswer(String content) async {
    try {
      await _repo.submitTodayAnswer(widget.roomId, content);
      await _load();
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.roomQuestionsTodayAnswer(widget.roomId),
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      context.showSnackBar(message);
    }
  }
}

class _InProgressFallback extends StatelessWidget {
  const _InProgressFallback({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '오늘의 질문을 불러오지 못했어요.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: '다시 시도',
              onPressed: onRetry,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameBottomBar extends StatelessWidget {
  const _GameBottomBar({
    required this.roomId,
  });

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.CIvory.withValues(alpha: 0.95),
            AppColors.CSkyBlue.withValues(alpha: 0.22),
            AppColors.CPink.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: AppColors.CTextPrimary.withValues(alpha: 0.1),
            width: AppTheme.borderWidthFocus,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomActionButton(
              label: '쪽지함',
              backgroundColor: AppColors.CYellow,
              foregroundColor: AppColors.CTextPrimary,
              icon: Icons.mail_outline,
              onTap: () => context.push(AppRoutes.roomNotesPath(roomId)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BottomActionButton(
              label: '쪽지 쓰기',
              backgroundColor: AppColors.CRed,
              foregroundColor: AppColors.CBackground,
              icon: Icons.edit_outlined,
              onTap: () => context.push(AppRoutes.roomLetterSendPath(roomId)),
            ),
          ),
          const SizedBox(width: 10),
          _IconBarButton(
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppRoutes.roomDemoPath(roomId)),
          ),
        ],
      ),
    );
  }
}

class _IconBarButton extends StatelessWidget {
  const _IconBarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.CBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.CTextPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(icon, color: AppColors.CTextPrimary),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.CTextPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: foregroundColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
