import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/paper_text_field.dart';
import 'main_room_page.dart';

class MissionInputPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final int missionCount;

  const MissionInputPage({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.missionCount,
  });

  @override
  State<MissionInputPage> createState() => _MissionInputPageState();
}

class _MissionInputPageState extends State<MissionInputPage> {
  late final List<TextEditingController> controllers;

  final List<List<String>> randomMissions = [
    ['아침에 만나면 윙크', '손하트 보내기', '귀엽다고 말하기'],
    ['커피나 간식 몰래 주기', '칭찬 한마디 하기', '같이 사진 찍기'],
    ['오늘 하루 응원하기', '좋아하는 노래 공유', '손편지 써주기'],
  ];

  final List<Color> tapeColors = const [
    Color(0xFF9FD8FF),
    Color(0xFFFFB3B3),
    Color(0xFFBEE8B2),
  ];

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
      widget.missionCount,
      (_) => TextEditingController(),
    );
  }

  void randomizeMission(int index) {
    final random = Random();
    final group = randomMissions[index % randomMissions.length];

    setState(() {
      controllers[index].text = group[random.nextInt(group.length)];
    });
  }

  void completeMissionInput() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainRoomPage(),
      ),
      (route) => false,
    );
  }

  Widget sticker(String text, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Text(
        text,
        style: TextStyle(fontSize: size),
      ),
    );
  }

  Widget missionCard({
    required int index,
    required Color tapeColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          left: 24,
          child: Transform.rotate(
            angle: -0.06,
            child: Container(
              width: 96,
              height: 24,
              decoration: BoxDecoration(
                color: tapeColor.withOpacity(0.82),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.line.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.line,
                    width: 1.6,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PaperTextField(
                  controller: controllers[index],
                  hint: '미션을 입력\n해주세요',
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => randomizeMission(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.subText,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            sticker('☀️', width - 82, 18, 54),
            sticker('🌼', 8, 90, 22),
            sticker('✨', width - 34, 234, 22),
            sticker('💗', 12, 286, 16),
            sticker('☺️', width - 72, 314, 28),
            sticker('🌸', width - 24, 404, 22),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 140),
              child: Column(
                children: [
                  const Text(
                    '미션 입력하기',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.roomName} 방의 미션 ${widget.missionCount}개를 적어주세요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(height: 42),
                  for (int i = 0; i < widget.missionCount; i++) ...[
                    missionCard(
                      index: i,
                      tapeColor: tapeColors[i % tapeColors.length],
                    ),
                    const SizedBox(height: 34),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.text,
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: AppColors.line),
                          ),
                        ),
                        child: const Text(
                          '이전',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 7,
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        onPressed: completeMissionInput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF08A43),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          '완료하기',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}