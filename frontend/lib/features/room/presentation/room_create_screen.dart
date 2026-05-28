import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/tomato_mascot.dart';
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

      if (!mounted) return;

      if (inviteCode.isEmpty) {
        throw ApiException(
          code: ErrorCode.unknown,
          message: '초대 코드가 응답에 없습니다.',
        );
      }

      context.push(
        AppRoutes.roomJoinProfilePath(
          invitationCode: inviteCode,
          missionCount: _missionCount,
        ),
      );
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
    // 생성 API 전 단계에서는 서버 저장 API가 명세에 없어 로컬 상태만 유지합니다.
    // 실제 서버 호출은 _submitCreateRoom()의 POST /rooms에서 수행합니다.
    setState(() {
      _selectedDate = date;
      _selectedTime = time;
      _dateTimeError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF5E6),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TomatoMascot(size: 34, variant: TomatoMascotVariant.excited),
            SizedBox(width: 8),
            Text('방 만들기'),
          ],
        ),
      ),
      body: SafeArea(
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
                    Transform.rotate(
                      angle: -1.5 * math.pi / 180,
                      child: RoomDescInput(
                        controller: _descController,
                        apiException: _descError,
                        onChanged: (_) => setState(() => _descError = null),
                      ),
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
                        style:
                            AppTextStyles.caption.copyWith(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('인당 미션 개수', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 8),
                    MissionCountSelector(
                      count: _missionCount,
                      onChanged: (value) => setState(() => _missionCount = value),
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
    );
  }
}
