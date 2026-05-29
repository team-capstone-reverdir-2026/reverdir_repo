import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
  final Future<void> Function(DateTime date, TimeOfDay time)? onSyncToServer;

  @override
  State<RoomDateTimePicker> createState() => _RoomDateTimePickerState();
}

class _RoomDateTimePickerState extends State<RoomDateTimePicker> {
  DateTime get _safeDate => widget.selectedDate ?? DateTime.now();
  TimeOfDay get _safeTime => widget.selectedTime ?? const TimeOfDay(hour: 18, minute: 0);

  Future<void> _syncToServerIfNeeded() async {
    if (widget.onSyncToServer == null) return;
    await widget.onSyncToServer!(_safeDate, _safeTime);
  }

  @override
  Widget build(BuildContext context) {
    final firstDate = DateTime.now().subtract(const Duration(days: 1));
    final lastDate = DateTime.now().add(const Duration(days: 3650));

    final datePanel = _CalendarDatePanel(
      selectedDate: _safeDate,
      firstDate: firstDate,
      lastDate: lastDate,
      onDateChanged: (date) {
        widget.onDateSelected(date);
        _syncToServerIfNeeded();
      },
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
      ],
    );
  }
}

/// 미션 카드 느낌의 파스텔 초록 달력 위젯 + 와시 테이프.
class _CalendarDatePanel extends StatelessWidget {
  const _CalendarDatePanel({
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.CGreen.withValues(alpha: 0.42),
                AppColors.CSkyBlue.withValues(alpha: 0.18),
                AppColors.CIvory,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: AppTheme.handDrawnBorder(
              color: AppColors.CGreen.withValues(alpha: 0.82),
              width: AppTheme.borderWidthFocus,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.CGreen.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '종료 일자',
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.CTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 300,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.CGreen,
                          onPrimary: AppColors.CBackground,
                        ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateChanged: onDateChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: -2,
          left: 28,
          child: WashiTape(
            color: WashiTapeColor.green,
            width: 92,
            rotation: -4,
          ),
        ),
        const Positioned(
          top: 4,
          right: 24,
          child: WashiTape(
            color: WashiTapeColor.yellow,
            width: 72,
            rotation: 6,
          ),
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.CTextPrimary),
          ),
          const SizedBox(height: 6),
          ClipRect(child: child),
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
  static int _minuteSlot(int minute) => ((minute + 5) ~/ 10) % 6;

  void _onChanged(int hour, int minute) {
    widget.onChanged(TimeOfDay(hour: hour, minute: minute));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _LoopingWheelColumn(
              label: '시',
              loopCount: 24,
              initialIndex: widget.time.hour,
              labelBuilder: (index) => index.toString().padLeft(2, '0'),
              onSelected: (index) =>
                  _onChanged(index, widget.time.minute),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(':', style: AppTextStyles.titleMedium),
          ),
          Expanded(
            child: _LoopingWheelColumn(
              label: '분',
              loopCount: 6,
              initialIndex: _minuteSlot(widget.time.minute),
              labelBuilder: (index) =>
                  (index * 10).toString().padLeft(2, '0'),
              onSelected: (index) =>
                  _onChanged(widget.time.hour, index * 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoopingWheelColumn extends StatefulWidget {
  const _LoopingWheelColumn({
    required this.label,
    required this.loopCount,
    required this.initialIndex,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String label;
  final int loopCount;
  final int initialIndex;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelected;

  @override
  State<_LoopingWheelColumn> createState() => _LoopingWheelColumnState();
}

class _LoopingWheelColumnState extends State<_LoopingWheelColumn> {
  static const _itemExtent = 40.0;
  static const _visibleRows = 3;
  static const _loopRepeats = 400;

  late final int _anchor;
  late FixedExtentScrollController _controller;

  static TextStyle get _wheelTextStyle => AppTextStyles.titleMedium.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  @override
  void initState() {
    super.initState();
    _anchor = widget.loopCount * _loopRepeats ~/ 2;
    final safeIndex = widget.initialIndex.clamp(0, widget.loopCount - 1);
    _controller = FixedExtentScrollController(
      initialItem: _anchor + safeIndex,
    );
    _controller.addListener(_recentreIfNeeded);
  }

  @override
  void didUpdateWidget(covariant _LoopingWheelColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      final target = _anchor + widget.initialIndex.clamp(0, widget.loopCount - 1);
      if (_controller.selectedItem != target) {
        _controller.jumpToItem(target);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_recentreIfNeeded);
    _controller.dispose();
    super.dispose();
  }

  int get _loopIndex => _controller.selectedItem % widget.loopCount;

  void _recentreIfNeeded() {
    if (!_controller.hasClients) return;
    final item = _controller.selectedItem;
    final low = widget.loopCount * 40;
    final high = widget.loopCount * (_loopRepeats - 40);
    if (item < low || item > high) {
      _controller.jumpToItem(_anchor + _loopIndex);
    }
  }

  void _handleSelection(int index) {
    final value = index % widget.loopCount;
    widget.onSelected(value);
  }

  /// Web·데스크톱 휠은 ListWheel 기본 스크롤이 2칸 이상 점프할 수 있어 직접 1칸만 이동.
  bool get _manualWheelStep =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  void _onPointerScroll(PointerSignalEvent event) {
    if (!_manualWheelStep || event is! PointerScrollEvent) return;
    if (!_controller.hasClients) return;
    final dy = event.scrollDelta.dy;
    if (dy == 0) return;
    final next = _controller.selectedItem + (dy > 0 ? 1 : -1);
    _controller.jumpToItem(next);
    _handleSelection(next);
  }

  @override
  Widget build(BuildContext context) {
    final wheelHeight = _itemExtent * _visibleRows;

    return Column(
      children: [
        Text(widget.label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        SizedBox(
          height: wheelHeight,
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
              ClipRect(
                child: SizedBox(
                  height: wheelHeight,
                  child: Listener(
                    onPointerSignal: _onPointerScroll,
                    child: ListWheelScrollView.useDelegate(
                      controller: _controller,
                      itemExtent: _itemExtent,
                      diameterRatio: 1.45,
                      perspective: 0.003,
                      physics: _manualWheelStep
                          ? const NeverScrollableScrollPhysics()
                          : const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: _handleSelection,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: widget.loopCount * _loopRepeats,
                        builder: (context, index) {
                          final loopIndex = index % widget.loopCount;
                          final selected = _controller.hasClients &&
                              _controller.selectedItem == index;
                          return Center(
                            child: Text(
                              widget.labelBuilder(loopIndex),
                              style: _wheelTextStyle.copyWith(
                                color: AppColors.CTextPrimary.withValues(
                                  alpha: selected ? 1 : 0.38,
                                ),
                              ),
                            ),
                          );
                        },
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
