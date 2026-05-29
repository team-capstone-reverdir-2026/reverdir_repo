import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/washi_tape.dart';

/// 참여자 목록 — [MissionListCard]와 같은 손그림 카드 스타일(오렌지 액센트).
class ParticipantsListPanel extends StatelessWidget {
  const ParticipantsListPanel({
    super.key,
    required this.title,
    required this.children,
    this.rotateAngle = 0.012,
    /// 바텀시트 등 뒤 화면 위에 띄울 때 — 배경을 완전 불투명하게.
    this.opaqueOverlay = false,
  });

  final String title;
  final List<Widget> children;
  final double rotateAngle;
  final bool opaqueOverlay;

  static const Color accent = AppColors.COrange;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotateAngle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: opaqueOverlay ? AppColors.CIvory : null,
              gradient: opaqueOverlay
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.38),
                        AppColors.CYellow.withValues(alpha: 0.18),
                        AppColors.CIvory,
                      ],
                    ),
              borderRadius: BorderRadius.circular(30),
              border: AppTheme.handDrawnBorder(
                color: opaqueOverlay
                    ? accent
                    : accent.withValues(alpha: 0.82),
                width: AppTheme.borderWidthFocus,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.CTextPrimary.withValues(
                    alpha: opaqueOverlay ? 0.14 : 0.08,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.CTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
          Positioned(
            top: -12,
            left: 24,
            child: WashiTape.horizontal(
              color: WashiTapeColor.orange,
              width: 88,
              rotation: -6,
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantNameRow extends StatelessWidget {
  const ParticipantNameRow({
    super.key,
    required this.name,
    this.isHost = false,
    this.trailing,
  });

  final String name;
  final bool isHost;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial =
        trimmed.isNotEmpty ? trimmed.characters.first : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isHost ? AppColors.CRed : AppColors.CBlue,
            child: Text(
              initial,
              style: AppTextStyles.label.copyWith(
                color: AppColors.CBackground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
