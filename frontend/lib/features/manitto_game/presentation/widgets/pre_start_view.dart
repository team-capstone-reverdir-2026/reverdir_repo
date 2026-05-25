import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/tomato_mascot.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../data/mock_game_service.dart';

class PreStartView extends StatefulWidget {
  const PreStartView({
    super.key,
    required this.service,
    required this.onStart,
  });

  final MockGameService service;
  final VoidCallback onStart;

  @override
  State<PreStartView> createState() => _PreStartViewState();
}

class _PreStartViewState extends State<PreStartView> {
  final _missionController = TextEditingController();

  @override
  void dispose() {
    _missionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.service,
      builder: (context, _) {
        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                54,
                20,
                widget.service.isHost ? 150 : 40,
              ),
              children: [
                _RoomIntro(service: widget.service),
                const SizedBox(height: 22),
                _ParticipantsCard(service: widget.service),
                const SizedBox(height: 22),
                _MissionDraftCard(
                  service: widget.service,
                  controller: _missionController,
                  onAdd: _addMission,
                  onRecommend: _recommendMission,
                ),
                const SizedBox(height: 24),
                if (!widget.service.isHost)
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
            if (widget.service.isHost)
              _HostStartBottomBar(onStart: widget.onStart),
          ],
        );
      },
    );
  }

  void _addMission() {
    final error = widget.service.addMyMission(_missionController.text);
    if (error != null) {
      context.showErrorSnackBar(error);
      return;
    }
    _missionController.clear();
  }

  void _recommendMission() {
    final mission = widget.service.recommendMission();
    _missionController
      ..text = mission
      ..selection = TextSelection.collapsed(offset: mission.length);
    context.showSnackBar('추천 미션을 채워뒀어요!');
  }
}

class _HostStartBottomBar extends StatelessWidget {
  const _HostStartBottomBar({required this.onStart});

  final VoidCallback onStart;

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
          label: '마니또 시작하기',
          onPressed: onStart,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _RoomIntro extends StatelessWidget {
  const _RoomIntro({required this.service});

  final MockGameService service;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.roomName,
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
                  service.roomDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.CTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '초대 코드 ${service.inviteCode}',
                  style: AppTextStyles.statusBadge.copyWith(
                    color: AppColors.CRed,
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
  const _ParticipantsCard({required this.service});

  final MockGameService service;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.014,
      child: Container(
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
            ...service.participants.map(
              (p) => Padding(
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
                        color: p.missionCount >= service.maxMissionCount
                            ? AppColors.CGreen.withValues(alpha: 0.48)
                            : AppColors.CYellow.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(999),
                        border: AppTheme.handDrawnBorder(
                          color: AppColors.CBrown,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${p.missionCount}/${service.maxMissionCount}개',
                        style: AppTextStyles.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionDraftCard extends StatelessWidget {
  const _MissionDraftCard({
    required this.service,
    required this.controller,
    required this.onAdd,
    required this.onRecommend,
  });

  final MockGameService service;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback onRecommend;

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
                  '내가 작성한 미션만 보여요. 최대 ${service.maxMissionCount}개까지 가능!',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 14),
                ...service.myPreStartMissions.map(
                  (mission) => _EditableMissionRow(
                    mission: mission,
                    onChanged: (value) =>
                        service.updateMyMission(mission.id, value),
                    onDelete: () => service.deleteMyMission(mission.id),
                  ),
                ),
                if (service.myPreStartMissions.length <
                    service.maxMissionCount) ...[
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
                          onTap: onRecommend,
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
                    onPressed: onAdd,
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
    required this.mission,
    required this.onChanged,
    required this.onDelete,
  });

  final EditableMission mission;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

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
            onPressed: widget.onDelete,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.CRed,
          ),
        ],
      ),
    );
  }
}
