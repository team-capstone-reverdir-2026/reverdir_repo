import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/paper_text_field.dart';
import 'mission_input_page.dart';
import 'room_api.dart';

class EnterRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String description;
  final int missionCount;

  const EnterRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.description,
    required this.missionCount,
  });

  @override
  State<EnterRoomPage> createState() => _EnterRoomPageState();
}

class _EnterRoomPageState extends State<EnterRoomPage> {
  final displayNameController = TextEditingController();
  bool isLoading = false;

  Future<void> handleEnterRoom() async {
    if (displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해 주세요')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await RoomApi.enterRoom(
      roomId: widget.roomId,
      displayName: displayNameController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MissionInputPage(
            roomId: widget.roomId,
            roomName: widget.roomName,
            missionCount: widget.missionCount,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 입장에 실패했습니다')),
      );
    }
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  Widget sticker(String text, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Text(text, style: TextStyle(fontSize: size)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            sticker('☁️', width - 86, 72, 36),
            sticker('💌', -10, 268, 38),
            sticker('💗', width - 58, 228, 18),
            sticker('✨', width - 62, 386, 28),
            sticker('🌼', 18, height - 136, 24),
            sticker('〰', width * 0.63, height - 72, 38),

            Positioned(
              top: 14,
              left: 18,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.text,
                  size: 28,
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 70, 22, 122),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 440,
                        minHeight: 520,
                      ),
                      padding: const EdgeInsets.fromLTRB(34, 112, 34, 54),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EDEE).withOpacity(0.48),
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(
                          color: AppColors.line.withOpacity(0.32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 44),
                          const Text(
                            '당신은 누구십니\n까?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              height: 1.35,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            '방에서 사용할 닉네임을 입력해\n주세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              height: 1.45,
                              fontWeight: FontWeight.w800,
                              color: AppColors.subText,
                            ),
                          ),
                          const SizedBox(height: 42),
                          SizedBox(
                            width: 250,
                            child: PaperTextField(
                              controller: displayNameController,
                              hint: '닉네임 입력',
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: -20,
                      right: 74,
                      child: Transform.rotate(
                        angle: -0.03,
                        child: Container(
                          width: 176,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withOpacity(0.68),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    const Positioned(
                      top: -38,
                      right: 28,
                      child: Text(
                        '⭐',
                        style: TextStyle(fontSize: 42),
                      ),
                    ),

                    const Positioned(
                      top: 30,
                      child: Text(
                        '🍅',
                        style: TextStyle(fontSize: 82),
                      ),
                    ),

                    const Positioned(
                      top: 104,
                      right: 112,
                      child: Text(
                        '☺',
                        style: TextStyle(
                          fontSize: 27,
                          color: AppColors.tomato,
                        ),
                      ),
                    ),
                  ],
                ),
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
                      height: 66,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.text,
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: AppColors.line),
                          ),
                        ),
                        child: const Text(
                          '이전',
                          style: TextStyle(
                            fontSize: 22,
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
                      height: 66,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleEnterRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tomato,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isLoading ? '입장 중...' : '다음 ✦',
                          style: const TextStyle(
                            fontSize: 24,
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