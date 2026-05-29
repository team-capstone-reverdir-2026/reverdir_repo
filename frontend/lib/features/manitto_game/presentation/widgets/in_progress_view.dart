import 'package:flutter/material.dart';

import '../../../../core/network/api_enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../../hint/presentation/widgets/hint_card.dart';
import '../../../hint/provider/hint_provider.dart';
import '../../../mission/presentation/widgets/mission_card.dart';
import '../../../mission/provider/mission_provider.dart';
import 'participants_list_panel.dart';
import 'room_name_with_mascot.dart';

/// 진행 중 방 메인 레이아웃 (GameMainScreen 본문).
class InProgressView extends StatelessWidget {
  const InProgressView({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.status,
    required this.daysRemaining,
    required this.participantNames,
    required this.todayQuestion,
    required this.missionProvider,
    this.onAnswerSubmitted,
    this.myManittiDisplayName,
    this.endsAt,
  });

  final String roomId;
  final String roomName;
  final RoomStatus status;
  final int daysRemaining;
  final List<String> participantNames;
  final TodayQuestionViewData todayQuestion;
  final MissionProvider missionProvider;
  final Future<void> Function(String)? onAnswerSubmitted;

  /// GET /rooms/{roomId}/my-manitti — null이면 비밀 UI
  final String? myManittiDisplayName;
  final DateTime? endsAt;

  @override
  Widget build(BuildContext context) {
    final dDayLabel = endsAt != null
        ? DateFormatter.formatDaysRemaining(endsAt)
        : 'D-$daysRemaining';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: _GameHeader(
              roomName: roomName,
              status: status,
              dDayLabel: dDayLabel,
              participantNames: participantNames,
              onParticipantsTap: () => _showParticipantsSheet(context),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _MyManittiCard(secretName: myManittiDisplayName),
              const SizedBox(height: 22),
              HintCard(
                roomId: roomId,
                data: todayQuestion,
                onAnswerSubmitted: onAnswerSubmitted,
              ),
              const SizedBox(height: 22),
              ListenableBuilder(
                listenable: missionProvider,
                builder: (_, __) => MissionListCard(provider: missionProvider),
              ),
              const SizedBox(height: 122),
            ]),
          ),
        ),
      ],
    );
  }

  void _showParticipantsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.CIvory,
      isScrollControlled: true,
      builder: (ctx) {
        return Material(
          color: AppColors.CIvory,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.CBrown.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ParticipantsListPanel(
                    title: '참여자',
                    rotateAngle: 0,
                    opaqueOverlay: true,
                    children: participantNames
                        .map((name) => ParticipantNameRow(name: name))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.roomName,
    required this.status,
    required this.dDayLabel,
    required this.participantNames,
    required this.onParticipantsTap,
  });

  final String roomName;
  final RoomStatus status;
  final String dDayLabel;
  final List<String> participantNames;
  final VoidCallback onParticipantsTap;

  static const double _actionsGap = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final actions = _HeaderActions(
          status: status,
          dDayLabel: dDayLabel,
          participantNames: participantNames,
          onParticipantsTap: onParticipantsTap,
        );
        final titleBlock = RoomNameWithMascot(
          roomName: roomName,
          mascotSize: compact ? 28 : 30,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: actions,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            SizedBox(width: _actionsGap),
            actions,
          ],
        );
      },
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.status,
    required this.dDayLabel,
    required this.participantNames,
    required this.onParticipantsTap,
  });

  final RoomStatus status;
  final String dDayLabel;
  final List<String> participantNames;
  final VoidCallback onParticipantsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.CGreen.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(999),
              border: AppTheme.handDrawnBorder(
                color: AppColors.CGreen.withValues(alpha: 0.90),
              ),
            ),
            child: Text(
              '${status.displayLabel} ($dDayLabel)',
              style: AppTheme.roomStatusLabel(status),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onParticipantsTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _AvatarDot(color: AppColors.CYellow),
                const _AvatarDot(color: AppColors.CSkyBlue),
                _MoreParticipantsBadge(count: participantNames.length),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '참여 인원',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.CTextSecondary,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}

class _AvatarDot extends StatelessWidget {
  const _AvatarDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.CIvory, width: 2),
      ),
    );
  }
}

class _MoreParticipantsBadge extends StatelessWidget {
  const _MoreParticipantsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final extra = count > 2 ? count - 2 : 0;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.CRed,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.CIvory, width: 2),
      ),
      child: Text(
        extra > 0 ? '+$extra' : '+',
        style: AppTextStyles.label.copyWith(
          color: AppColors.CBackground,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _MyManittiCard extends StatelessWidget {
  const _MyManittiCard({this.secretName});

  final String? secretName;

  @override
  Widget build(BuildContext context) {
    final revealed = secretName != null && secretName!.isNotEmpty;

    return Transform.rotate(
      angle: 0.014,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.CPink.withValues(alpha: 0.36),
                  AppColors.CYellow.withValues(alpha: 0.26),
                  AppColors.CIvory,
                ],
              ),
              borderRadius: AppTheme.borderRadius,
              border: AppTheme.handDrawnBorder(
                color: AppColors.CPink.withValues(alpha: 0.70),
                width: AppTheme.borderWidthFocus,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.CPink.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.CBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.CRed.withValues(alpha: 0.35),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 32,
                    color: AppColors.CRed.withValues(alpha: 0.48),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내가 챙겨줄 마니띠는...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.CTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revealed ? secretName! : '비밀이에요! 🤫',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.CRed,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            left: 24,
            child: WashiTape.horizontal(
              color: WashiTapeColor.yellow,
              width: 70,
              rotation: -8,
            ),
          ),
        ],
      ),
    );
  }
}
