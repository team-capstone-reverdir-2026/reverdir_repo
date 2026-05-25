import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_enums.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../provider/game_provider.dart';
import 'widgets/in_progress_view.dart';

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
  // ── 임시 UI 테스트 플래그 (true/false로 전환 후 Hot Reload) ─────────────
  static const bool debugLoadingMode = false;
  static const bool debugErrorMode = false;
  static const bool debugMyAnswered = false;
  static const bool debugManittoAnswered = true;

  final _gameProvider = GameProvider();

  @override
  void initState() {
    super.initState();
    _gameProvider.addListener(_onProviderChanged);
    if (!debugLoadingMode && !debugErrorMode) {
      _gameProvider.loadRoom(widget.roomId).then((_) {
        _gameProvider.applyDebugQuestionFlags(
          myAnswered: debugMyAnswered,
          manittoAnswered: debugManittoAnswered,
        );
      });
    }
  }

  @override
  void dispose() {
    _gameProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      body: DoodleBackground(
        child: Stack(
          children: [
            _buildBody(),
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

    if (debugLoadingMode) {
      return const Center(child: LoadingIndicator(size: 40));
    }

    if (debugErrorMode) {
      return ErrorView.fromApiException(
        ApiException(
          code: ErrorCode.gameNotEnded,
          message: ErrorCode.gameNotEnded.displayLabel,
        ),
        onRetry: () {
          // TODO: _gameProvider.loadRoom(widget.roomId);
        },
      );
    }

    if (_gameProvider.isLoading) {
      return const Center(child: LoadingIndicator(size: 40));
    }

    if (_gameProvider.hasError && _gameProvider.error != null) {
      return ErrorView.fromApiException(
        _gameProvider.error!,
        onRetry: () => _gameProvider.loadRoom(widget.roomId),
      );
    }

    final question = _gameProvider.todayQuestion;
    final missions = _gameProvider.missionProvider;
    if (question == null || missions == null) {
      return const Center(child: LoadingIndicator());
    }

    final debugQuestion = question.copyWithDebug(
      myAnswered: debugMyAnswered,
      manittoAnswered: debugManittoAnswered,
    );

    return InProgressView(
      roomId: widget.roomId,
      roomName: _gameProvider.roomName,
      status: _gameProvider.roomStatus,
      daysRemaining: _gameProvider.daysRemaining,
      participantNames: _gameProvider.participantNames,
      todayQuestion: debugQuestion,
      missionProvider: missions,
      myManittiDisplayName: _gameProvider.myManittiName,
    );
  }

  Widget _buildDebugBanner() {
    return Positioned(
      top: MediaQuery.paddingOf(context).top,
      left: 8,
      right: 8,
      child: Material(
        color: AppColors.COrange.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'DEBUG loading=$debugLoadingMode error=$debugErrorMode '
            'my=$debugMyAnswered manitto=$debugManittoAnswered',
            style: AppTextStyles.caption,
          ),
        ),
      ),
    );
  }
}

class _GameBottomBar extends StatelessWidget {
  const _GameBottomBar({required this.roomId});

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
          _IconBarButton(
            icon: Icons.settings_outlined,
            onTap: () {
              // TODO: 데모 관리 페이지 라우트 추가 후 연결
              context.push('${AppRoutes.roomDetailPath(roomId)}/demo-admin');
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BottomActionButton(
              label: '쪽지함',
              backgroundColor: AppColors.CYellow,
              foregroundColor: AppColors.CTextPrimary,
              icon: Icons.mail_outline,
              onTap: () => context.push(AppRoutes.roomNotesPath(roomId)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BottomActionButton(
              label: '쪽지 쓰기',
              backgroundColor: AppColors.CRed,
              foregroundColor: AppColors.CBackground,
              icon: Icons.edit_outlined,
              onTap: () {
                // TODO: LetterSender 화면/모달 라우트
                context.push(AppRoutes.roomNotesPath(roomId));
              },
            ),
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
  final VoidCallback onTap;

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
