import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../hint/provider/hint_provider.dart';
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
  });

  final String roomId;

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
  List<MissionUiItem> _missions = const [];
  TodayQuestionViewData? _todayQuestion;
  String? _myManittiName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
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
    final question = _todayQuestion;
    if (detail == null || question == null) {
      return const SizedBox.shrink();
    }
    final phase = switch (detail.status) {
      RoomStatus.waiting => GamePhase.preStart,
      RoomStatus.inProgress => GamePhase.inProgress,
      RoomStatus.ended => GamePhase.finished,
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (phase) {
        GamePhase.preStart => PreStartView(
            key: const ValueKey(GamePhase.preStart),
            roomName: detail.name,
            roomDescription: detail.description,
            inviteCode: '',
            maxMissionCount: _missions.length,
            isHost: detail.isHost,
            participants: _participants,
            myMissions: _draftMissions,
            onStart: _startGame,
            onAddMission: _addMission,
            onRecommend: _repo.recommendMission,
            onUpdateMission: _updateMission,
            onDeleteMission: _deleteMission,
          ),
        GamePhase.inProgress => InProgressView(
            key: const ValueKey(GamePhase.inProgress),
            roomId: widget.roomId,
            roomName: detail.name,
            status: detail.status,
            daysRemaining: detail.daysRemaining,
            participantNames:
                _participants.map((e) => e.displayName).toList(growable: false),
            todayQuestion: question,
            missionProvider: MissionProvider(
              _missions,
              onToggleRemote: (missionId, isCompleted) {
                return _repo.patchMission(
                  widget.roomId,
                  missionId,
                  isCompleted: isCompleted,
                );
              },
            ),
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
    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final detail = await _repo.fetchRoomDetail(widget.roomId);
      final participants = await _repo.fetchParticipants(widget.roomId);
      final missions = await _repo.fetchMissions(widget.roomId);
      final question = await _repo.fetchTodayQuestion(widget.roomId);
      String? myManitti;
      try {
        myManitti = await _repo.fetchMyManittiName(widget.roomId);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _participants = participants;
        _missions = missions;
        _draftMissions = missions
            .map((m) => EditableMission(id: m.id, content: m.content))
            .toList(growable: false);
        _todayQuestion = question;
        _myManittiName = myManitti;
      });
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'GET',
        url: ApiEndpoints.room(widget.roomId),
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startGame() async {
    await _repo.startGame(widget.roomId);
    await _load();
  }

  Future<void> _addMission(String content) async {
    await _repo.addMission(widget.roomId, content);
    await _load();
  }

  Future<void> _updateMission(String missionId, String content) async {
    await _repo.patchMission(widget.roomId, missionId, content: content);
    await _load();
  }

  Future<void> _deleteMission(String missionId) async {
    await _repo.deleteMission(widget.roomId, missionId);
    await _load();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
