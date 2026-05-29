import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tomato_mascot.dart';

/// 방 이름 + 토마토 마스코트 — 우측 고정 위젯 영역을 침범하지 않도록 [Flexible]로 제한.
class RoomNameWithMascot extends StatelessWidget {
  const RoomNameWithMascot({
    super.key,
    required this.roomName,
    this.mascotSize = 30,
    this.mascotVariant = TomatoMascotVariant.excited,
    this.nameMascotGap = 8,
    this.maxLines = 2,
  });

  final String roomName;
  final double mascotSize;
  final TomatoMascotVariant mascotVariant;
  final double nameMascotGap;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            roomName,
            style: AppTextStyles.titleLarge,
            maxLines: maxLines,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: nameMascotGap),
        TomatoMascot(
          variant: mascotVariant,
          size: mascotSize,
        ),
      ],
    );
  }
}
