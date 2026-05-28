import '../../../core/network/api_client.dart';
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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status:
          RoomStatus.tryParse(json['status'] as String?) ?? RoomStatus.waiting,
      participantCount: json['participantCount'] as int? ?? 0,
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
      roomId: json['roomId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      missionCount: json['missionCount'] as int? ?? 0,
      participantCount: json['participantCount'] as int? ?? 0,
    );
  }
}

class MainRepository {
  const MainRepository({ApiClient? client}) : _client = client;

  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  Future<List<RoomSummaryData>> fetchMyRooms() async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.rooms);
    final rooms = (res.data?['rooms'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
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
