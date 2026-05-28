import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RoomApi {
  RoomApi._();

  static const String _roomsKey = 'demo_rooms';

  static Future<List<Map<String, dynamic>>> _loadRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_roomsKey);

    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> _saveRooms(List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomsKey, jsonEncode(rooms));
  }

  static String _computedStatus(Map<String, dynamic> room) {
    final rawStatus = room['status'];

    if (rawStatus == 'IN_PROGRESS' || rawStatus == 'ENDED') {
      return rawStatus;
    }

    final endsAtRaw = room['endsAt'];
    if (endsAtRaw is String) {
      final endsAt = DateTime.tryParse(endsAtRaw);
      if (endsAt != null && DateTime.now().isAfter(endsAt)) {
        return 'ENDED';
      }
    }

    return 'WAITING';
  }

  static Future<List<dynamic>> getRooms() async {
    await Future.delayed(const Duration(milliseconds: 250));

    final rooms = await _loadRooms();

    for (final room in rooms) {
      room['status'] = _computedStatus(room);
    }

    await _saveRooms(rooms);
    return rooms;
  }

  static Future<Map<String, dynamic>?> createRoom({
    required String name,
    required String description,
    required String endsAt,
    required int missionCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final rooms = await _loadRooms();
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';

    final room = {
      'id': roomId,
      'roomId': roomId,
      'name': name,
      'description': description,
      'status': 'WAITING',
      'participantCount': 1,
      'missionCount': missionCount,
      'inviteCode': 'TOMATO',
      'endsAt': endsAt,
      'createdAt': DateTime.now().toIso8601String(),
    };

    rooms.insert(0, room);
    await _saveRooms(rooms);

    return room;
  }

  static Future<Map<String, dynamic>?> joinRoom({
    required String inviteCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (inviteCode.length != 6) return null;

    final rooms = await _loadRooms();

    final roomId = 'room_joined_$inviteCode';

    final room = {
      'id': roomId,
      'roomId': roomId,
      'name': '초대받은 마니또 방',
      'description': '초대 코드로 입장한 방입니다',
      'status': 'WAITING',
      'participantCount': 4,
      'missionCount': 3,
      'inviteCode': inviteCode,
      'endsAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    final exists = rooms.any((item) => item['roomId'] == roomId);
    if (!exists) {
      rooms.insert(0, room);
      await _saveRooms(rooms);
    }

    return room;
  }

  static Future<bool> enterRoom({
    required String roomId,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return displayName.trim().isNotEmpty;
  }

  static Future<void> updateRoomStatus({
    required String roomId,
    required String status,
  }) async {
    final rooms = await _loadRooms();

    final index = rooms.indexWhere((room) => room['roomId'] == roomId);
    if (index == -1) return;

    rooms[index]['status'] = status;
    await _saveRooms(rooms);
  }

  static Future<void> deleteRoom(String roomId) async {
    final rooms = await _loadRooms();
    rooms.removeWhere((room) => room['roomId'] == roomId);
    await _saveRooms(rooms);
  }
}