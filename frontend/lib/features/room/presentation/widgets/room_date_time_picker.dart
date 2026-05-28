import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomDateTimePicker extends StatefulWidget {
  const RoomDateTimePicker({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
    this.selectedDate,
    this.selectedTime,
    this.onSyncToServer,
  });

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;

  /// 부모에서 실제 API 호출로 동기화할 때 사용합니다.
  final Future<void> Function(DateTime date, TimeOfDay time)? onSyncToServer;

  @override
  State<RoomDateTimePicker> createState() => _RoomDateTimePickerState();
}

class _RoomDateTimePickerState extends State<RoomDateTimePicker> {
  String? _errorText;

  DateTime get _safeDate => widget.selectedDate ?? DateTime.now();
  TimeOfDay get _safeTime => widget.selectedTime ?? TimeOfDay.now();

  String _dateLabel(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _syncToServerIfNeeded() async {
    if (widget.onSyncToServer == null) return;
    try {
      setState(() => _errorText = null);
      await widget.onSyncToServer!(_safeDate, _safeTime);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'API 호출/응답 문제: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'API 호출/응답 문제: 날짜/시간 저장에 실패했습니다.');
    }
  }

  Future<void> _openDatePickerPopup(BuildContext context) async {
    var tempDate = _safeDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _PickerPopupFrame(
        title: 'Due Date',
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: tempDate,
          minimumDate: DateTime.now().subtract(const Duration(days: 1)),
          maximumDate: DateTime.now().add(const Duration(days: 3650)),
          onDateTimeChanged: (picked) => tempDate = picked,
        ),
        onConfirm: () async {
          widget.onDateSelected(tempDate);
          await _syncToServerIfNeeded();
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _openTimePickerPopup(BuildContext context) async {
    final initial = DateTime(
      2000,
      1,
      1,
      _safeTime.hour,
      _safeTime.minute,
    );
    var temp = initial;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _PickerPopupFrame(
        title: 'Due Time',
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          minuteInterval: 1,
          initialDateTime: temp,
          onDateTimeChanged: (picked) => temp = picked,
        ),
        onConfirm: () async {
          widget.onTimeSelected(TimeOfDay(hour: temp.hour, minute: temp.minute));
          await _syncToServerIfNeeded();
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _TiltedKitschButton(
              label: '날짜 ${_dateLabel(_safeDate)}',
              color: AppColors.CYellow.withValues(alpha: 0.6),
              onTap: () => _openDatePickerPopup(context),
            ),
            _TiltedKitschButton(
              label: '시간 ${_timeLabel(_safeTime)}',
              color: AppColors.CSkyBlue.withValues(alpha: 0.6),
              onTap: () => _openTimePickerPopup(context),
            ),
          ],
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.CRed),
          ),
        ],
      ],
    );
  }
}

class _TiltedKitschButton extends StatelessWidget {
  const _TiltedKitschButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -2.2 * math.pi / 180,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.CBrown, width: 1.4),
            ),
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
        ),
      ),
    );
  }
}

class _PickerPopupFrame extends StatelessWidget {
  const _PickerPopupFrame({
    required this.title,
    required this.child,
    required this.onConfirm,
  });

  final String title;
  final Widget child;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                Text(title, style: AppTextStyles.titleSmall),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onConfirm,
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
