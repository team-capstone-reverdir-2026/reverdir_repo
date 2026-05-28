import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/doodle_background.dart';
import '../data/mock_game_service.dart';
import 'widgets/finished_view.dart';
import 'widgets/in_progress_view.dart';
import 'widgets/pre_start_view.dart';

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
  final _service = MockGameService.instance;

  @override
  void initState() {
    super.initState();
    _service.hydrateFromBackend(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      body: AnimatedBuilder(
        animation: _service,
        builder: (context, _) {
          return DoodleBackground(
            child: Stack(
              children: [
                _buildBody(),
                if (_service.isHydrating)
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: _SyncBadge(),
                  ),
                if (_service.phase == GamePhase.inProgress)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _GameBottomBar(
                      roomId: widget.roomId,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_service.phase) {
        GamePhase.preStart => PreStartView(
            key: const ValueKey(GamePhase.preStart),
            service: _service,
            onStart: _service.startGame,
          ),
        GamePhase.inProgress => InProgressView(
            key: const ValueKey(GamePhase.inProgress),
            roomId: widget.roomId,
            roomName: _service.roomName,
            status: _service.roomStatus,
            daysRemaining: _service.daysRemaining,
            participantNames: _service.participantNames,
            todayQuestion: _service.todayQuestion,
            missionProvider: _service.inProgressMissions,
            onAnswerSubmitted: _service.submitTodayAnswer,
            myManittiDisplayName: null,
            endsAt: _service.endsAt,
          ),
        GamePhase.finished => FinishedView(
            key: const ValueKey(GamePhase.finished),
            service: _service,
            onOpenLetters: () =>
                context.push(AppRoutes.roomNotesPath(widget.roomId)),
            onOpenResults: () =>
                context.push(AppRoutes.roomResultsPath(widget.roomId)),
          ),
      },
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.CBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: AppColors.CTextPrimary.withValues(alpha: 0.12)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
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
