import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/utils/json_parse.dart';
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
    required this.missionCount,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String description;
  final RoomStatus status;
  final DateTime? endsAt;
  final int daysRemaining;
  final bool isHost;
  final int participantCount;
  final int missionCount;
  final String? inviteCode;

  factory RoomDetailData.fromJson(Map<String, dynamic> json) => RoomDetailData(
        id: parseJsonString(json['id']),
        name: parseJsonString(json['name']),
        description: parseJsonString(json['description']),
        status: RoomStatus.tryParse(parseJsonString(json['status'])) ??
            RoomStatus.waiting,
        endsAt: DateTime.tryParse(parseJsonString(json['endsAt'])),
        daysRemaining: parseJsonInt(json['daysRemaining']),
        isHost: parseJsonBool(json['isHost']),
        participantCount: parseJsonInt(json['participantCount']),
        missionCount: parseJsonInt(json['missionCount']),
        inviteCode: json['inviteCode'] == null
            ? null
            : parseJsonString(json['inviteCode']),
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
        userId: parseJsonString(json['userId']),
        displayName: parseJsonString(json['displayName']),
        missionCount: parseJsonInt(json['missionCount']),
        isHost: parseJsonBool(json['isHost']),
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

class RoomMissionsData {
  const RoomMissionsData({
    required this.missions,
    required this.maxCount,
  });

  final List<MissionUiItem> missions;
  final int maxCount;
}

class ManittoPersonData {
  const ManittoPersonData({required this.userId, required this.displayName});
  final String userId;
  final String displayName;
  factory ManittoPersonData.fromJson(Map<String, dynamic> json) =>
      ManittoPersonData(
        userId: parseJsonString(json['userId']),
        displayName: parseJsonString(json['displayName']),
      );
}

class ManittoChainData {
  const ManittoChainData({required this.manitto, required this.manitti});
  final ManittoPersonData manitto;
  final ManittoPersonData manitti;
  factory ManittoChainData.fromJson(Map<String, dynamic> json) => ManittoChainData(
        manitto: ManittoPersonData.fromJson(
          parseJsonMap(json['manitto']) ?? const {},
        ),
        manitti: ManittoPersonData.fromJson(
          parseJsonMap(json['manitti']) ?? const {},
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
        date: parseJsonString(json['date']),
        question: parseJsonString(json['question']),
        myAnswer: json['myAnswer'] == null
            ? null
            : parseJsonString(json['myAnswer']),
        manittoAnswer: json['manitoAnswer'] == null
            ? null
            : parseJsonString(json['manitoAnswer']),
        isBlurred: parseJsonBool(json['isBlurred']),
      );
}

class GameRepository {
  const GameRepository({ApiClient? client}) : _client = client;
  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  static const Duration _aiReportTimeout = Duration(minutes: 5);

  Future<RoomDetailData> fetchRoomDetail(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.room(roomId));
    return RoomDetailData.fromJson(res.data ?? const {});
  }

  Future<List<ParticipantData>> fetchParticipants(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomParticipants(roomId),
    );
    final list = parseJsonMapList(res.data?['participants']);
    return list.map(ParticipantData.fromJson).toList();
  }

  Future<RoomMissionsData> fetchMissions(String roomId) async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.roomMissions(roomId));
    final list = parseJsonMapList(res.data?['missions']);
    return RoomMissionsData(
      missions: list.map(MissionUiItem.fromApiJson).toList(),
      maxCount: parseJsonInt(res.data?['maxCount']),
    );
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
    return parseJsonString(res.data?['content']);
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
    final name = parseJsonString(res.data?['displayName']).trim();
    if (name.isEmpty) return null;
    return name;
  }

  Future<void> startGame(String roomId) async {
    await _api.post<Map<String, dynamic>>(ApiEndpoints.roomGameStart(roomId));
  }

  Future<List<QuestionHistoryData>> fetchQuestionHistory(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomQuestionsHistory(roomId),
    );
    final list = parseJsonMapList(res.data?['history']);
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
      parseJsonMap(data['myManitto']) ?? const {},
    );
    final chain = parseJsonMapList(data['chain'])
        .map(ManittoChainData.fromJson)
        .toList();
    return (myManitto, chain);
  }

  Future<PersonalReportData> fetchMyReport(String roomId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomResultsMyReport(roomId),
      options: Options(
        connectTimeout: _aiReportTimeout,
        receiveTimeout: _aiReportTimeout,
        sendTimeout: _aiReportTimeout,
      ),
    );
    final data = res.data ?? const {};
    final status =
        ReportStatus.tryParse(parseJsonString(data['status'])) ??
            ReportStatus.pending;
    return PersonalReportData(
      status: status,
      typeName: parseJsonString(data['typeName']),
      storyText: parseJsonString(data['storyText']),
      typeImageUrl: data['typeImageUrl'] == null
          ? null
          : parseJsonString(data['typeImageUrl']),
    );
  }
}
