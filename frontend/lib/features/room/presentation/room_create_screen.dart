import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../../core/widgets/tomato_mascot.dart';
import '../data/room_invite_code_cache.dart';
import 'widgets/mission_count_selector.dart';
import 'widgets/room_date_time_picker.dart';
import 'widgets/room_desc_input.dart';
import 'widgets/room_nameinput.dart';

class RoomCreateScreen extends StatefulWidget {
  const RoomCreateScreen({super.key});

  @override
  State<RoomCreateScreen> createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends State<RoomCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _missionCount = 3;
  bool _submitting = false;

  ApiException? _nameError;
  ApiException? _descError;
  ApiException? _dateTimeError;
  ApiException? _missionCountError;

  String _apiPath(String endpointPath) => '/api/v1$endpointPath';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitCreateRoom() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = ApiException(
          code: ErrorCode.validationError,
          message: '방 이름을 입력해 주세요.',
        );
      });
      return;
    }

    final due = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() {
      _submitting = true;
      _nameError = null;
      _descError = null;
      _dateTimeError = null;
      _missionCountError = null;
    });

    try {
      final res = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rooms,
        data: {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'endsAt': due.toUtc().toIso8601String(),
          'missionCount': _missionCount,
        },
      );

      final data = res.data ?? const <String, dynamic>{};
      final inviteCode = (data['inviteCode'] as String?)?.trim() ?? '';
      final roomId = (data['roomId'] as String?)?.trim() ?? '';

      if (!mounted) return;

      if (roomId.isEmpty) {
        throw ApiException(
          code: ErrorCode.unknown,
          message: '방 ID가 응답에 없습니다.',
        );
      }

      if (inviteCode.isNotEmpty) {
        RoomInviteCodeCache.save(roomId, inviteCode);
        context.push(
          AppRoutes.roomJoinProfilePath(
            roomId: roomId,
            invitationCode: inviteCode,
            missionCount: _missionCount,
          ),
        );
      } else {
        context.go(AppRoutes.roomDetailPath(roomId));
      }
    } catch (e, s) {
      final snackBarMessage =
          '[API 에러] POST ${_apiPath(ApiEndpoints.rooms)} 연결 실패 - 서버 상태를 확인하세요.';
      developer.log(
        snackBarMessage,
        name: 'ReverdirApi',
        error: e,
        stackTrace: s,
      );

      if (e is ApiException) {
        setState(() {
          _nameError = e;
          _descError = e;
          _dateTimeError = e;
          _missionCountError = e;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _syncDateTime(DateTime date, TimeOfDay time) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = time;
      _dateTimeError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.CBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TomatoMascot(size: 34, variant: TomatoMascotVariant.excited),
            SizedBox(width: 8),
            Text('방 만들기'),
          ],
        ),
      ),
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('방 이름', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      RoomNameInput(
                        controller: _nameController,
                        apiException: _nameError,
                        onChanged: (_) => setState(() => _nameError = null),
                      ),
                      const SizedBox(height: 20),
                      Text('방 소개', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      RoomDescInput(
                        controller: _descController,
                        apiException: _descError,
                        onChanged: (_) => setState(() => _descError = null),
                      ),
                      const SizedBox(height: 20),
                      Text('종료 일시', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      RoomDateTimePicker(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onDateSelected: (date) =>
                            setState(() => _selectedDate = date),
                        onTimeSelected: (time) =>
                            setState(() => _selectedTime = time),
                        onSyncToServer: _syncDateTime,
                      ),
                      if (_dateTimeError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'API 호출/응답 문제: ${_dateTimeError!.message}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.CRed),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('인당 미션 개수', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      MissionCountSelector(
                        count: _missionCount,
                        onChanged: (value) =>
                            setState(() => _missionCount = value),
                        apiException: _missionCountError,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: CustomButton(
                  label: _submitting ? '생성 중...' : '방 만들기 완료 🍅',
                  width: double.infinity,
                  onPressed: _submitting ? null : _submitCreateRoom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
