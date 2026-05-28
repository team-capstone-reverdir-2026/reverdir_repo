import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/tomato_mascot.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../data/game_repository.dart';

class PreStartView extends StatefulWidget {
  const PreStartView({
    super.key,
    required this.roomName,
    required this.roomDescription,
    required this.inviteCode,
    required this.maxMissionCount,
    required this.isHost,
    required this.participants,
    required this.myMissions,
    required this.myMissionCount,
    this.myDisplayName,
    required this.onStart,
    required this.onAddMission,
    required this.onRecommend,
    required this.onUpdateMission,
    required this.onDeleteMission,
  });

  final String roomName;
  final String roomDescription;
  final String inviteCode;
  final int maxMissionCount;
  final bool isHost;
  final List<ParticipantData> participants;
  final List<EditableMission> myMissions;
  final int myMissionCount;
  final String? myDisplayName;
  final Future<void> Function() onStart;
  final Future<void> Function(String content) onAddMission;
  final Future<String> Function() onRecommend;
  final Future<void> Function(String missionId, String content) onUpdateMission;
  final Future<void> Function(String missionId) onDeleteMission;

  @override
  State<PreStartView> createState() => _PreStartViewState();
}

class _PreStartViewState extends State<PreStartView> {
  final _missionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _missionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            54,
            20,
            widget.isHost ? 150 : 40,
          ),
          children: [
            _RoomIntro(
              roomName: widget.roomName,
              roomDescription: widget.roomDescription,
              inviteCode: widget.inviteCode,
            ),
            const SizedBox(height: 22),
            _ParticipantsCard(
              participants: widget.participants,
              maxMissionCount: widget.maxMissionCount,
              myMissionCount: widget.myMissionCount,
              myDisplayName: widget.myDisplayName,
            ),
            const SizedBox(height: 22),
            _MissionDraftCard(
              maxMissionCount: widget.maxMissionCount,
              myMissions: widget.myMissions,
              controller: _missionController,
              onAdd: _addMission,
              onRecommend: _recommendMission,
              onUpdateMission: widget.onUpdateMission,
              onDeleteMission: widget.onDeleteMission,
            ),
            const SizedBox(height: 24),
            if (!widget.isHost)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.CBrown.withValues(alpha: 0.25),
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Text(
                  '방장이 게임을 시작할 때까지 기다려 주세요.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        if (widget.isHost)
          _HostStartBottomBar(
            onStart: _startGame,
            disabled: _submitting,
          ),
      ],
    );
  }

  Future<void> _startGame() async {
    try {
      setState(() => _submitting = true);
      await widget.onStart();
    } catch (e) {
      if (!mounted) return;
      context.showUserError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _addMission() async {
    final trimmed = _missionController.text.trim();
    if (trimmed.isEmpty) {
      context.showErrorSnackBar('미션 내용을 입력해 주세요.');
      return;
    }
    try {
      await widget.onAddMission(trimmed);
      _missionController.clear();
    } catch (e) {
      if (!mounted) return;
      context.showUserError(e);
    }
  }

  Future<void> _recommendMission() async {
    try {
      final mission = await widget.onRecommend();
      _missionController
        ..text = mission
        ..selection = TextSelection.collapsed(offset: mission.length);
      if (!mounted) return;
      context.showSnackBar('추천 미션을 채워뒀어요!');
    } catch (e) {
      if (!mounted) return;
      context.showUserError(e);
    }
  }
}

class _HostStartBottomBar extends StatelessWidget {
  const _HostStartBottomBar({required this.onStart, required this.disabled});

  final VoidCallback onStart;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.CIvory.withValues(alpha: 0.96),
              AppColors.CYellow.withValues(alpha: 0.30),
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
        child: CustomButton(
          label: disabled ? '시작 중...' : '마니또 시작하기',
          onPressed: disabled ? null : onStart,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _RoomIntro extends StatelessWidget {
  const _RoomIntro({
    required this.roomName,
    required this.roomDescription,
    required this.inviteCode,
  });
  final String roomName;
  final String roomDescription;
  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.012,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.CRed.withValues(alpha: 0.24),
                  AppColors.CYellow.withValues(alpha: 0.34),
                  AppColors.CIvory,
                ],
              ),
              borderRadius: AppTheme.borderRadius,
              border: AppTheme.handDrawnBorder(color: AppColors.CRed),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: inviteCode.isNotEmpty ? 40 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              roomName,
                              style: AppTextStyles.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const TomatoMascot(
                            variant: TomatoMascotVariant.peeking,
                            size: 34,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        roomDescription,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.CTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (inviteCode.isNotEmpty)
                  Positioned(
                    right: 4,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '초대 코드',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.CTextSecondary,
                          ),
                        ),
                        Text(
                          inviteCode,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.CRed,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            right: 28,
            child: WashiTape.horizontal(
              color: WashiTapeColor.orange,
              width: 84,
              rotation: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({
    required this.participants,
    required this.maxMissionCount,
    required this.myMissionCount,
    this.myDisplayName,
  });
  final List<ParticipantData> participants;
  final int maxMissionCount;
  final int myMissionCount;
  final String? myDisplayName;

  int _missionCountFor(ParticipantData participant) {
    final mine = myDisplayName?.trim();
    if (mine != null &&
        mine.isNotEmpty &&
        participant.displayName.trim() == mine) {
      return myMissionCount;
    }
    return participant.missionCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.CSkyBlue.withValues(alpha: 0.22),
          borderRadius: AppTheme.borderRadius,
          border: AppTheme.handDrawnBorder(color: AppColors.CSkyBlue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('참여자 미션 준비 현황', style: AppTextStyles.titleMedium),
            const SizedBox(height: 14),
            ...participants.map(
              (p) {
                final entered = _missionCountFor(p);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            p.isHost ? AppColors.CRed : AppColors.CBlue,
                        child: Text(
                          p.displayName.characters.first,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.CBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: AppTextStyles.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: entered >= maxMissionCount
                              ? AppColors.CGreen.withValues(alpha: 0.48)
                              : AppColors.CYellow.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(999),
                          border: AppTheme.handDrawnBorder(
                            color: AppColors.CBrown,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$entered/$maxMissionCount개',
                          style: AppTextStyles.label,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
    );
  }
}

class _MissionDraftCard extends StatelessWidget {
  const _MissionDraftCard({
    required this.maxMissionCount,
    required this.myMissions,
    required this.controller,
    required this.onAdd,
    required this.onRecommend,
    required this.onUpdateMission,
    required this.onDeleteMission,
  });

  final int maxMissionCount;
  final List<EditableMission> myMissions;
  final TextEditingController controller;
  final Future<void> Function() onAdd;
  final Future<void> Function() onRecommend;
  final Future<void> Function(String missionId, String content) onUpdateMission;
  final Future<void> Function(String missionId) onDeleteMission;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.01,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.CIvory,
              borderRadius: AppTheme.borderRadius,
              border: AppTheme.handDrawnBorder(color: AppColors.COrange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('나의 시작 전 미션', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '내가 작성한 미션만 보여요. 최대 $maxMissionCount개까지 가능!',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 14),
                ...myMissions.map(
                  (mission) => _EditableMissionRow(
                    key: ValueKey(mission.id),
                    mission: mission,
                    onChanged: (value) => onUpdateMission(mission.id, value),
                    onDelete: () => onDeleteMission(mission.id),
                  ),
                ),
                if (myMissions.length < maxMissionCount) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: controller,
                          hint: '예: 몰래 칭찬 스티커 붙여주기',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => onAdd(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.CYellow.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => onRecommend(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: AppTheme.handDrawnBorder(
                                color: AppColors.COrange,
                                width: 1.4,
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.CTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: '미션 추가하기',
                    onPressed: () => onAdd(),
                    variant: CustomButtonVariant.outlined,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: -10,
            left: 24,
            child: WashiTape.horizontal(
              color: WashiTapeColor.yellow,
              width: 88,
              rotation: -7,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableMissionRow extends StatefulWidget {
  const _EditableMissionRow({
    super.key,
    required this.mission,
    required this.onChanged,
    required this.onDelete,
  });

  final EditableMission mission;
  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onDelete;

  @override
  State<_EditableMissionRow> createState() => _EditableMissionRowState();
}

class _EditableMissionRowState extends State<_EditableMissionRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.mission.content);
  }

  @override
  void didUpdateWidget(covariant _EditableMissionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mission.id != widget.mission.id ||
        oldWidget.mission.content != widget.mission.content) {
      _controller.text = widget.mission.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: widget.onChanged,
            ),
          ),
          IconButton(
            onPressed: () => widget.onDelete(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.CRed,
          ),
        ],
      ),
    );
  }
}
