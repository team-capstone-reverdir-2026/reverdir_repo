import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

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
  final Future<void> Function(DateTime date, TimeOfDay time)? onSyncToServer;

  @override
  State<RoomDateTimePicker> createState() => _RoomDateTimePickerState();
}

class _RoomDateTimePickerState extends State<RoomDateTimePicker> {
  String? _errorText;

  DateTime get _safeDate => widget.selectedDate ?? DateTime.now();
  TimeOfDay get _safeTime => widget.selectedTime ?? const TimeOfDay(hour: 18, minute: 0);

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

  @override
  Widget build(BuildContext context) {
    final firstDate = DateTime.now().subtract(const Duration(days: 1));
    final lastDate = DateTime.now().add(const Duration(days: 3650));

    final datePanel = _PickerPanel(
      title: '종료 일자',
      accent: AppColors.CYellow,
      child: SizedBox(
        height: 300,
        child: CalendarDatePicker(
          initialDate: _safeDate,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: (date) {
            widget.onDateSelected(date);
            _syncToServerIfNeeded();
          },
        ),
      ),
    );

    final timePanel = _PickerPanel(
      title: '종료 시각',
      accent: AppColors.CSkyBlue,
      child: _TimeWheelPicker(
        time: _safeTime,
        onChanged: (time) {
          widget.onTimeSelected(time);
          _syncToServerIfNeeded();
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  datePanel,
                  const SizedBox(height: 12),
                  timePanel,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: datePanel),
                const SizedBox(width: 12),
                Expanded(child: timePanel),
              ],
            );
          },
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

class _PickerPanel extends StatelessWidget {
  const _PickerPanel({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.42),
            AppColors.CIvory,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: AppTheme.handDrawnBorder(
          color: accent.withValues(alpha: 0.75),
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.CTextPrimary),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _TimeWheelPicker extends StatefulWidget {
  const _TimeWheelPicker({
    required this.time,
    required this.onChanged,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<_TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<_TimeWheelPicker> {
  static const _itemExtent = 40.0;
  static const _visibleCount = 3;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: widget.time.hour);
    _minuteController =
        FixedExtentScrollController(initialItem: widget.time.minute);
  }

  @override
  void didUpdateWidget(covariant _TimeWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time.hour != widget.time.hour &&
        _hourController.selectedItem != widget.time.hour) {
      _hourController.jumpToItem(widget.time.hour);
    }
    if (oldWidget.time.minute != widget.time.minute &&
        _minuteController.selectedItem != widget.time.minute) {
      _minuteController.jumpToItem(widget.time.minute);
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      TimeOfDay(
        hour: _hourController.selectedItem,
        minute: _minuteController.selectedItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wheelHeight = _itemExtent * _visibleCount;

    return SizedBox(
      height: wheelHeight + 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _ScrollWheelColumn(
              label: '시',
              controller: _hourController,
              itemCount: 24,
              formatter: (i) => i.toString().padLeft(2, '0'),
              onSelected: _notify,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(':', style: AppTextStyles.titleMedium),
          ),
          Expanded(
            child: _ScrollWheelColumn(
              label: '분',
              controller: _minuteController,
              itemCount: 60,
              formatter: (i) => i.toString().padLeft(2, '0'),
              onSelected: _notify,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollWheelColumn extends StatelessWidget {
  const _ScrollWheelColumn({
    required this.label,
    required this.controller,
    required this.itemCount,
    required this.formatter,
    required this.onSelected,
  });

  final String label;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) formatter;
  final VoidCallback onSelected;

  static const _itemExtent = 40.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 4,
                right: 4,
                height: _itemExtent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.CBackground.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.CBrown.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: _itemExtent,
                diameterRatio: 1.35,
                perspective: 0.004,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (_) => onSelected(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (context, index) {
                    final selected = controller.selectedItem == index;
                    return Center(
                      child: Text(
                        formatter(index),
                        style: selected
                            ? AppTextStyles.titleMedium.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              )
                            : AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                color: AppColors.CTextTertiary
                                    .withValues(alpha: 0.75),
                              ),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.CIvory.withValues(alpha: 0.92),
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.CIvory.withValues(alpha: 0.92),
                        ],
                        stops: const [0, 0.22, 0.78, 1],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
