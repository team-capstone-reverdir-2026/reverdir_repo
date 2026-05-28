import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../hint/provider/hint_provider.dart';
import '../../mission/provider/mission_provider.dart';

class RoomDetailData {
  const RoomDetailData({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.endsAt,
    required this.daysRemaining,
    required this.isHost,
    required this.participantCount,
  });

  final String id;
  final String name;
  final String description;
  final RoomStatus status;
  final DateTime? endsAt;
  final int daysRemaining;
  final bool isHost;
  final int participantCount;

  factory RoomDetailData.fromJson(Map<String, dynamic> json) => RoomDetailData(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: RoomStatus.tryParse(json['status'] as String?) ?? RoomStatus.waiting,
        endsAt: DateTime.tryParse(json['endsAt'] as String? ?? ''),
        daysRemaining: json['daysRemaining'] as int? ?? 0,
        isHost: json['isHost'] as bool? ?? false,
        participantCount: json['participantCount'] as int? ?? 0,
      );
}

class ParticipantData {
  const ParticipantData({
    required this.userId,
    required this.displayName,
    required this.missionCount,
    required this.isHost,
  });

  final String userId;
  final String displayName;
  final int missionCount;
  final bool isHost;

  factory ParticipantData.fromJson(Map<String, dynamic> json) => ParticipantData(
        userId: json['userId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        missionCount: json['missionCount'] as int? ?? 0,
        isHost: json['isHost'] as bool? ?? false,
      );
}

class EditableMission {
  const EditableMission({
    required this.id,
    required this.content,
  });
  final String id;
  final String content;
}

class ManittoPersonData {
  const ManittoPersonData({required this.userId, required this.displayName});
  final String userId;
  final String displayName;
  factory ManittoPersonData.fromJson(Map<String, dynamic> json) =>
      ManittoPersonData(
        userId: json['userId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
      );
}

class ManittoChainData {
  const ManittoChainData({required this.manitto, required this.manitti});
  final ManittoPersonData manitto;
  final ManittoPersonData manitti;
  factory ManittoChainData.fromJson(Map<String, dynamic> json) => ManittoChainData(
        manitto: ManittoPersonData.fromJson(
          (json['manitto'] as Map<String, dynamic>?) ?? const {},
        ),
        manitti: ManittoPersonData.fromJson(
          (json['manitti'] as Map<String, dynamic>?) ?? const {},
        ),
      );
}

class PersonalReportData {
  const PersonalReportData({
    required this.status,
    required this.typeName,
    required this.storyText,
    this.typeImageUrl,
  });
  final ReportStatus status;
  final String typeName;
  final String storyText;
  final String? typeImageUrl;
}

class QuestionHistoryData {
  const QuestionHistoryData({
    required this.date,
    required this.question,
    required this.myAnswer,
    required this.manittoAnswer,
    required this.isBlurred,
  });
  final String date;
  final String question;
  final String? myAnswer;
  final String? manittoAnswer;
  final bool isBlurred;

  factory QuestionHistoryData.fromJson(Map<String, dynamic> json) =>
      QuestionHistoryData(
        date: json['date'] as String? ?? '',
        question: json['question'] as String? ?? '',
        myAnswer: json['myAnswer'] as String?,
        manittoAnswer: json['manitoAnswer'] as String?,
        isBlurred: json['isBlurred'] as bool? ?? false,
      );
}

class GameRepository {
  const GameRepository({ApiClient? client}) : _client = client;
  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  Future<RoomDetailData> fetchRoomDetail(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.room(roomId));
    return RoomDetailData.fromJson(res.data ?? const {});
  }

  Future<List<ParticipantData>> fetchParticipants(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomParticipants(roomId),
    );
    final list = (res.data?['participants'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return list.map(ParticipantData.fromJson).toList();
  }

  Future<List<MissionUiItem>> fetchMissions(String roomId) async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.roomMissions(roomId));
    final list = (res.data?['missions'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return list.map(MissionUiItem.fromApiJson).toList();
  }

  Future<void> patchMission(
    String roomId,
    String missionId, {
    bool? isCompleted,
    String? content,
  }) async {
    await _api.patch<Map<String, dynamic>>(
      ApiEndpoints.roomMission(roomId, missionId),
      data: {
        if (isCompleted != null) 'isCompleted': isCompleted,
        if (content != null) 'content': content,
      },
    );
  }

  Future<void> addMission(String roomId, String content) async {
    await _api.post<Map<String, dynamic>>(
      ApiEndpoints.roomMissions(roomId),
      data: {'content': content},
    );
  }

  Future<void> deleteMission(String roomId, String missionId) async {
    await _api.delete<void>(ApiEndpoints.roomMission(roomId, missionId));
  }

  Future<String> recommendMission() async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.missionsRandom);
    return res.data?['content'] as String? ?? '';
  }

  Future<TodayQuestionViewData> fetchTodayQuestion(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomQuestionsToday(roomId),
    );
    return TodayQuestionViewData.fromApiJson(res.data ?? const {});
  }

  Future<void> submitTodayAnswer(String roomId, String content) async {
    await _api.post<Map<String, dynamic>>(
      ApiEndpoints.roomQuestionsTodayAnswer(roomId),
      data: {'content': content},
    );
  }

  Future<String?> fetchMyManittiName(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.roomMyManitti(roomId));
    final name = (res.data?['displayName'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  Future<void> startGame(String roomId) async {
    await _api.post<Map<String, dynamic>>(ApiEndpoints.roomGameStart(roomId));
  }

  Future<List<QuestionHistoryData>> fetchQuestionHistory(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomQuestionsHistory(roomId),
    );
    final list = (res.data?['history'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return list.map(QuestionHistoryData.fromJson).toList();
  }

  Future<(ManittoPersonData, List<ManittoChainData>)> fetchRevealResult(
    String roomId,
  ) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomResultsManittoReveal(roomId),
    );
    final data = res.data ?? const {};
    final myManitto = ManittoPersonData.fromJson(
      (data['myManitto'] as Map<String, dynamic>?) ?? const {},
    );
    final chain = ((data['chain'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ManittoChainData.fromJson)
        .toList();
    return (myManitto, chain);
  }

  Future<PersonalReportData> fetchMyReport(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomResultsMyReport(roomId),
    );
    final data = res.data ?? const {};
    final status = ReportStatus.tryParse(data['status'] as String?) ?? ReportStatus.pending;
    return PersonalReportData(
      status: status,
      typeName: data['typeName'] as String? ?? '',
      storyText: data['storyText'] as String? ?? '',
      typeImageUrl: data['typeImageUrl'] as String?,
    );
  }
}

