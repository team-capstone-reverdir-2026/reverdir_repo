import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_tracker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/main_repository.dart';

class RoomJoinPreviewScreen extends StatefulWidget {
  const RoomJoinPreviewScreen({
    super.key,
    required this.inviteCode,
  });

  final String inviteCode;

  @override
  State<RoomJoinPreviewScreen> createState() => _RoomJoinPreviewScreenState();
}

class _RoomJoinPreviewScreenState extends State<RoomJoinPreviewScreen> {
  final _repo = const MainRepository();
  bool _loading = true;
  String? _apiError;
  RoomJoinPreviewData? _preview;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 입장 페이지'),
        leading: const AppBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _apiError != null
                ? Text(_apiError!, style: AppTextStyles.bodySmall)
                : _preview == null
                    ? Text('방 정보를 불러오지 못했어요.', style: AppTextStyles.bodyMedium)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_preview!.name, style: AppTextStyles.titleLarge),
                          const SizedBox(height: 8),
                          Text(_preview!.description,
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 6),
                          Text(
                            '미션 수 ${_preview!.missionCount} · 참여자 ${_preview!.participantCount}',
                            style: AppTextStyles.caption,
                          ),
                          const Spacer(),
                          CustomButton(
                            label: '이 방으로 이동',
                            onPressed: () => context
                                .go(AppRoutes.roomDetailPath(_preview!.roomId)),
                            width: double.infinity,
                          ),
                        ],
                      ),
      ),
    );
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final p = await _repo.previewJoinCode(widget.inviteCode);
      if (!mounted) return;
      setState(() => _preview = p);
    } catch (e, s) {
      final message = ApiErrorTracker.logAndBuildMessage(
        method: 'POST',
        url: ApiEndpoints.roomsJoin,
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() => _apiError = message);
      context.showSnackBar(message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
