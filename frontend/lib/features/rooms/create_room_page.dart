import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/paper_text_field.dart';
import 'enter_room_page.dart';
import 'room_api.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay selectedTime = const TimeOfDay(hour: 23, minute: 59);

  int missionCount = 3;
  bool isLoading = false;

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (result != null) {
      setState(() => selectedTime = result);
    }
  }

  String get endsAt {
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    return dateTime.toIso8601String();
  }

  Future<void> handleCreateRoom() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해 주세요')),
      );
      return;
    }

    setState(() => isLoading = true);

    final room = await RoomApi.createRoom(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      endsAt: endsAt,
      missionCount: missionCount,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 생성에 실패했습니다')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EnterRoomPage(
          roomId: room['roomId'],
          roomName: room['name'],
          description: room['description'],
          missionCount: room['missionCount'],
        ),
      ),
    );
  }

  Widget sticker(String text, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Text(text, style: TextStyle(fontSize: size)),
    );
  }

  Widget stepTitle(int number, String title, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget waveDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: Text(
          '〰',
          style: TextStyle(
            fontSize: 28,
            color: AppColors.line,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget dateTimeBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line.withOpacity(0.7)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${selectedDate.year} / ${selectedDate.month.toString().padLeft(2, '0')} / ${selectedDate.day.toString().padLeft(2, '0')}';
    final timeText =
        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            sticker('🌷', 7, 70, 38),
            sticker('✨', 8, 134, 24),
            sticker('✉️', 300, 300, 60),
            sticker('✏️', 170, 450, 50),
            sticker('☀️', MediaQuery.of(context).size.width - 82, 42, 80),
            sticker(
              '🌱',
              MediaQuery.of(context).size.width - 44,
              MediaQuery.of(context).size.height - 110,
              24,
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      const Spacer(),
                      const Text(
                        '방 만들기 ✦',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(28, 44, 28, 34),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7DD).withOpacity(0.38),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: AppColors.line.withOpacity(0.38),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.035),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              stepTitle(1, '방 이름  ☺', AppColors.yellow),
                              const SizedBox(height: 16),
                              PaperTextField(
                                controller: nameController,
                                hint: '방의 이름을 입력해 주세요',
                              ),

                              waveDivider(),

                              stepTitle(2, '방 소개', AppColors.blue),
                              const SizedBox(height: 16),
                              PaperTextField(
                                controller: descriptionController,
                                hint: '어떤 사람들과의 모임인지 입력해 주세요',
                                maxLines: 3,
                              ),

                              waveDivider(),

                              stepTitle(3, '종료 일자 및 시각', AppColors.orange),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  dateTimeBox(
                                    title: '종료일자',
                                    value: dateText,
                                    onTap: pickDate,
                                  ),
                                  const SizedBox(width: 14),
                                  dateTimeBox(
                                    title: '종료시각',
                                    value: timeText,
                                    onTap: pickTime,
                                  ),
                                ],
                              ),

                              waveDivider(),

                              stepTitle(4, '미션 개수', AppColors.green),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.72),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: AppColors.line.withOpacity(0.7),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: missionCount > 1
                                          ? () {
                                              setState(() => missionCount--);
                                            }
                                          : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 32,
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '$missionCount개',
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.tomato,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: missionCount < 10
                                          ? () {
                                              setState(() => missionCount++);
                                            }
                                          : null,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: -13,
                          left: 118,
                          right: 118,
                          child: Transform.rotate(
                            angle: -0.04,
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.38),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 28,
              right: 28,
              bottom: 24,
              child: SizedBox(
                height: 70,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleCreateRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    isLoading ? '생성 중...' : '새로운 방 만들기',
                    style: const TextStyle(
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
    );
  }
}