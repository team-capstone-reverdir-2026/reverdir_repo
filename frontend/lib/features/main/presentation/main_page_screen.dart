import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../../core/widgets/logout_button.dart';
import '../../main/data/main_repository.dart';
import '../../room/data/room_invite_code_cache.dart';
import 'widgets/invite_code_dialog.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final _repo = const MainRepository();
  bool _loading = true;
  String? _apiError;
  List<RoomSummaryData> _rooms = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('참여 중인 방'),
        actions: const [LogoutButton(compact: true)],
      ),
      body: DoodleBackground(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_apiError != null) _ErrorBanner(message: _apiError!),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                      ? Center(
                          child: Text('참여 중인 방이 없어요.',
                              style: AppTextStyles.bodyMedium),
                        )
                      : ListView.separated(
                          itemCount: _rooms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return _RoomCard(
                              room: room,
                              onTap: () => context
                                  .push(AppRoutes.roomDetailPath(room.id)),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: '방 만들기',
              onPressed: () => context.push(AppRoutes.roomCreate),
              variant: CustomButtonVariant.outlined,
              width: double.infinity,
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: '방 입장하기',
              onPressed: _openInviteDialog,
              width: double.infinity,
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final items = await _repo.fetchMyRooms();
      if (!mounted) return;
      setState(() => _rooms = items);
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'GET',
        url: ApiEndpoints.rooms,
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: AppTextStyles.errorMessage)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openInviteDialog() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const InviteCodeDialog(),
    );
    if (code == null || code.length != 6) return;
    try {
      final preview = await _repo.previewJoinCode(code);
      if (!mounted) return;
      if (preview.roomId.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('방 정보를 찾지 못했습니다. 초대 코드를 다시 확인해 주세요.'),
          ),
        );
        return;
      }
      RoomInviteCodeCache.save(preview.roomId, code);
      context.push(
        AppRoutes.roomJoinProfilePath(
          roomId: preview.roomId,
          invitationCode: code,
          missionCount: preview.missionCount <= 0 ? 1 : preview.missionCount,
        ),
      );
    } catch (e, s) {
      if (e is ApiException && e.code == ErrorCode.alreadyJoined) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '이미 참여 중인 방이에요. 아래 목록에서 방을 선택해 주세요.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        );
        await _load();
        return;
      }
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.roomsJoin,
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: AppTextStyles.errorMessage)),
      );
    }
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});
  final RoomSummaryData room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.CIvory,
          borderRadius: AppTheme.borderRadius,
          border: AppTheme.handDrawnBorder(color: AppColors.CBrown),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(room.name,
                  style: AppTextStyles.roomName,
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.roomStatusBackground(room.status),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(room.status.displayLabel,
                  style: AppTextStyles.statusBadge),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.CRed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: AppTextStyles.bodySmall),
    );
  }
}
