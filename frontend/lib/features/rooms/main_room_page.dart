import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/tomato_button.dart';
import '../auth/auth_api.dart';
import 'create_room_page.dart';
import 'enter_room_page.dart';
import 'room_api.dart';

class MainRoomPage extends StatefulWidget {
  const MainRoomPage({super.key});

  @override
  State<MainRoomPage> createState() => _MainRoomPageState();
}

class _MainRoomPageState extends State<MainRoomPage> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  Uint8List? avatarBytes;
  String userName = '나';

  @override
  void initState() {
    super.initState();
    loadRooms();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final avatar = await AuthApi.getAvatarBytes();
    final name = await AuthApi.getUserName();

    if (!mounted) return;

    setState(() {
      avatarBytes = avatar;
      userName = name;
    });
  }

  Future<void> loadRooms() async {
    final result = await RoomApi.getRooms();

    if (!mounted) return;

    setState(() {
      rooms = result;
      isLoading = false;
    });
  }

  Future<void> changeRoomStatus(String roomId, String status) async {
    await RoomApi.updateRoomStatus(roomId: roomId, status: status);
    await loadRooms();
  }

  Future<void> deleteRoom(String roomId) async {
    await RoomApi.deleteRoom(roomId);
    await loadRooms();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'WAITING':
        return '기다리는 중...';
      case 'IN_PROGRESS':
        return '진행 중';
      case 'ENDED':
        return '종료';
      default:
        return '기다리는 중...';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'WAITING':
        return AppColors.orange;
      case 'IN_PROGRESS':
        return AppColors.green;
      case 'ENDED':
        return AppColors.subText;
      default:
        return AppColors.orange;
    }
  }

  Color cardColor(int index) {
    final colors = [
      const Color(0xFFEFF5EA),
      const Color(0xFFFFF0DF),
      const Color(0xFFFFF7E8),
    ];
    return colors[index % colors.length];
  }

  Color tapeColor(int index) {
    final colors = [
      AppColors.yellow,
      AppColors.tomato,
      AppColors.blue,
    ];
    return colors[index % colors.length].withOpacity(0.55);
  }

  Future<void> showInviteCodeDialog() async {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 360,
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '초대 코드 입력',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '6자리 코드를 입력해 주세요',
                      style: TextStyle(
                        color: AppColors.subText,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: codeController,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: 'OOOOOO',
                      ),
                    ),
                    const SizedBox(height: 24),
                    TomatoButton(
                      text: '입장하기',
                      onTap: () async {
                        final code = codeController.text.trim();

                        if (code.length != 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('초대 코드는 6자리입니다'),
                            ),
                          );
                          return;
                        }

                        final room = await RoomApi.joinRoom(inviteCode: code);

                        if (!mounted) return;
                        Navigator.pop(context);

                        if (room == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('유효하지 않은 초대 코드입니다'),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EnterRoomPage(
                              roomId: room['roomId'],
                              roomName: room['name'],
                              description: room['description'],
                              missionCount: room['missionCount'] ?? 3,
                            ),
                          ),
                        ).then((_) {
                          loadRooms();
                          loadUserProfile();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStatusAction(String status, String roomId) {
    if (status == 'WAITING') {
      return ElevatedButton(
        onPressed: () => changeRoomStatus(roomId, 'IN_PROGRESS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          '시작',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      );
    }

    if (status == 'IN_PROGRESS') {
      return ElevatedButton(
        onPressed: () => changeRoomStatus(roomId, 'ENDED'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.subText,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          '종료',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      );
    }

    return const Text(
      '완료',
      style: TextStyle(
        color: AppColors.subText,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget buildRoomCard(dynamic room, int index) {
    final status = room['status'] ?? 'WAITING';
    final isEnded = status == 'ENDED';
    final roomId = room['roomId'] ?? room['id'] ?? '';

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: AppColors.paper,
              title: const Text('방 삭제'),
              content: const Text('이 방을 삭제할까요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteRoom(roomId);
                  },
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 26),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 46, 28, 28),
              decoration: BoxDecoration(
                color: cardColor(index).withOpacity(0.84),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.line.withOpacity(0.55)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: statusColor(status).withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      statusLabel(status),
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    room['name'] ?? '이름 없는 방',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: isEnded ? AppColors.subText : AppColors.text,
                      decoration: isEnded ? TextDecoration.lineThrough : null,
                      decorationThickness: 3,
                    ),
                  ),
                  if ((room['description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      room['description'],
                      style: const TextStyle(
                        color: AppColors.subText,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 22,
                        color: AppColors.subText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${room['participantCount'] ?? 1}명 참여',
                        style: const TextStyle(
                          color: AppColors.subText,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      buildStatusAction(status, roomId),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -12,
              left: 28,
              child: Transform.rotate(
                angle: index.isEven ? -0.04 : 0.05,
                child: Container(
                  width: 140,
                  height: 28,
                  decoration: BoxDecoration(
                    color: tapeColor(index),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Positioned(
              right: -8,
              bottom: -12,
              child: Text('✨', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Text('🍅', style: TextStyle(fontSize: 54)),
            SizedBox(height: 18),
            Text(
              '아직 만든 방이 없어요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '+ 방 만들기를 눌러 첫 마니또 방을 만들어 보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              '나의 마니또\n방',
              style: TextStyle(
                fontSize: 34,
                height: 1.25,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          ),
          const Text('🍅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.yellow,
            backgroundImage:
                avatarBytes != null ? MemoryImage(avatarBytes!) : null,
            child: avatarBytes == null
                ? Text(
                    userName.isNotEmpty ? userName[0] : '나',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TomatoButton(
            text: '+ 방 만들기',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRoomPage()),
              );
              loadRooms();
              loadUserProfile();
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 58,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: showInviteCodeDialog,
              icon: const Icon(Icons.login),
              label: const Text(
                '초대 코드로 입장하기',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.line, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : rooms.isEmpty
                      ? buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
                          itemCount: rooms.length,
                          itemBuilder: (_, index) {
                            return buildRoomCard(rooms[index], index);
                          },
                        ),
            ),
            buildBottomButtons(),
          ],
        ),
      ),
    );
  }
}