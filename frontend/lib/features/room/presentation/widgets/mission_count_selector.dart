import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MissionCountSelector extends StatefulWidget {
  const MissionCountSelector({
    super.key,
    required this.count,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.apiException,
  });

  final int count;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final ApiException? apiException;

  @override
  State<MissionCountSelector> createState() => _MissionCountSelectorState();
}

class _MissionCountSelectorState extends State<MissionCountSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.92,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bounce() async {
    await _controller.reverse();
    if (!mounted) return;
    await _controller.forward();
  }

  void _decrease() {
    if (widget.count <= widget.min) return;
    widget.onChanged(widget.count - 1);
    _bounce();
  }

  void _increase() {
    if (widget.count >= widget.max) return;
    widget.onChanged(widget.count + 1);
    _bounce();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.CIvory,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.CBrown, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _controller,
                child: IconButton(
                  onPressed: _decrease,
                  icon: const Icon(Icons.remove_rounded),
                  color: AppColors.CTextPrimary,
                ),
              ),
              Container(
                width: 64,
                alignment: Alignment.center,
                child: Text(
                  '${widget.count}',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              ScaleTransition(
                scale: _controller,
                child: IconButton(
                  onPressed: _increase,
                  icon: const Icon(Icons.add_rounded),
                  color: AppColors.CTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
