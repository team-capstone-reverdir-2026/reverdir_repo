import '../../../core/network/api_client.dart';
import '../../../core/utils/json_parse.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';

class RoomSummaryData {
  const RoomSummaryData({
    required this.id,
    required this.name,
    required this.status,
    required this.participantCount,
  });

  final String id;
  final String name;
  final RoomStatus status;
  final int participantCount;

  factory RoomSummaryData.fromJson(Map<String, dynamic> json) {
    return RoomSummaryData(
      id: parseJsonString(json['id']),
      name: parseJsonString(json['name']),
      status: RoomStatus.tryParse(parseJsonString(json['status'])) ??
          RoomStatus.waiting,
      participantCount: parseJsonInt(json['participantCount']),
    );
  }
}

class RoomJoinPreviewData {
  const RoomJoinPreviewData({
    required this.roomId,
    required this.name,
    required this.description,
    required this.missionCount,
    required this.participantCount,
  });

  final String roomId;
  final String name;
  final String description;
  final int missionCount;
  final int participantCount;

  factory RoomJoinPreviewData.fromJson(Map<String, dynamic> json) {
    return RoomJoinPreviewData(
      roomId: parseJsonString(json['roomId']),
      name: parseJsonString(json['name']),
      description: parseJsonString(json['description']),
      missionCount: parseJsonInt(json['missionCount']),
      participantCount: parseJsonInt(json['participantCount']),
    );
  }
}

class MainRepository {
  const MainRepository({ApiClient? client}) : _client = client;

  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  Future<List<RoomSummaryData>> fetchMyRooms() async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.rooms);
    final rooms = parseJsonMapList(res.data?['rooms']);
    return rooms.map(RoomSummaryData.fromJson).toList();
  }

  Future<RoomJoinPreviewData> previewJoinCode(String inviteCode) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.roomsJoin,
      data: {'inviteCode': inviteCode},
    );
    return RoomJoinPreviewData.fromJson(res.data ?? const {});
  }
}
