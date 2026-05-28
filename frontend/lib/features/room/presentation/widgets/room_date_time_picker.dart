import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/washi_tape.dart';

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
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedTime = widget.selectedTime ?? TimeOfDay.now();
  }

  @override
  void didUpdateWidget(covariant RoomDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null && widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate!;
    }
    if (widget.selectedTime != null && widget.selectedTime != oldWidget.selectedTime) {
      _selectedTime = widget.selectedTime!;
    }
  }

  String _dateLabel(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _syncToServerIfNeeded() async {
    if (widget.onSyncToServer == null) return;
    try {
      setState(() => _errorText = null);
      await widget.onSyncToServer!(_selectedDate, _selectedTime);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'API 호출/응답 문제: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'API 호출/응답 문제: 날짜/시간 저장에 실패했습니다.');
    }
  }

  Future<void> _openDatePickerPopup(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.CRed,
              onPrimary: AppColors.CBackground,
              surface: AppColors.CIvory,
              onSurface: AppColors.CTextPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.CIvory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: AppTheme.handDrawnBorderSide(color: AppColors.CBrown),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    widget.onDateSelected(picked);
    await _syncToServerIfNeeded();
  }

  Future<void> _openTimePickerPopup(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.CRed,
              onPrimary: AppColors.CBackground,
              surface: AppColors.CIvory,
              onSurface: AppColors.CTextPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedTime = picked);
    widget.onTimeSelected(picked);
    await _syncToServerIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.rotate(
          angle: 0.006,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.CYellow.withValues(alpha: 0.42),
                      AppColors.CPink.withValues(alpha: 0.25),
                      AppColors.CIvory,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: AppTheme.handDrawnBorder(color: AppColors.CBrown),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _TiltedKitschButton(
                      label: '날짜 ${_dateLabel(_selectedDate)}',
                      color: AppColors.CYellow.withValues(alpha: 0.65),
                      onTap: () => _openDatePickerPopup(context),
                    ),
                    _TiltedKitschButton(
                      label: '시간 ${_timeLabel(_selectedTime)}',
                      color: AppColors.CSkyBlue.withValues(alpha: 0.6),
                      onTap: () => _openTimePickerPopup(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -8,
                right: 16,
                child: WashiTape.horizontal(
                  color: WashiTapeColor.orange,
                  width: 74,
                  rotation: 8,
                ),
              ),
              const Positioned(
                left: 10,
                top: 6,
                child: Icon(Icons.auto_awesome, color: AppColors.COrange, size: 16),
              ),
              const Positioned(
                right: 10,
                bottom: 8,
                child: Icon(Icons.favorite, color: AppColors.CPink, size: 15),
              ),
            ],
          ),
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
      angle: -1.5 * math.pi / 180,
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
              border: AppTheme.handDrawnBorder(color: AppColors.CBrown, width: 1.3),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
