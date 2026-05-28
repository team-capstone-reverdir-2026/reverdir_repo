import 'package:flutter/material.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

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
    final errorText = widget.apiException == null
        ? null
        : 'API 호출/응답 문제: ${widget.apiException!.message}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.CYellow.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(18),
            border: AppTheme.handDrawnBorder(color: AppColors.CBrown, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScaleTransition(
                scale: _controller,
                child: _CountRoundButton(
                  icon: Icons.remove_rounded,
                  onTap: _decrease,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '인당 ${widget.count}개',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
              ),
              ScaleTransition(
                scale: _controller,
                child: _CountRoundButton(
                  icon: Icons.add_rounded,
                  onTap: _increase,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: AppTextStyles.caption.copyWith(color: AppColors.CRed),
          ),
        ],
      ],
    );
  }
}

class _CountRoundButton extends StatelessWidget {
  const _CountRoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.CBackground.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: AppTheme.handDrawnBorder(color: AppColors.CBrown, width: 1),
          ),
          child: Icon(icon, color: AppColors.CTextPrimary, size: 20),
        ),
      ),
    );
  }
}
