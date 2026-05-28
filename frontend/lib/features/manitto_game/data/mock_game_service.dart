import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/error_handler.dart';
import '../../hint/provider/hint_provider.dart';
import '../../mission/provider/mission_provider.dart';

/// 화면 상태 — RoomStatus(WAITING/IN_PROGRESS/ENDED)를 UI 흐름에 맞게 감싼 값.
enum GamePhase { preStart, inProgress, finished }

class ParticipantProgress {
  const ParticipantProgress({
    required this.userId,
    required this.displayName,
    required this.missionCount,
    required this.isHost,
  });

  final String userId;
  final String displayName;
  final int missionCount;
  final bool isHost;
}

class EditableMission {
  const EditableMission({
    required this.id,
    required this.content,
  });

  final String id;
  final String content;

  EditableMission copyWith({String? content}) => EditableMission(
        id: id,
        content: content ?? this.content,
      );
}

class QuestionHistoryViewData {
  const QuestionHistoryViewData({
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
}

class LetterNote {
  const LetterNote({
    required this.id,
    required this.content,
    required this.isRead,
    required this.sentAt,
    required this.direction,
  });

  final String id;
  final String content;
  final bool isRead;
  final DateTime sentAt;
  final NoteDirection direction;

  LetterNote copyWith({bool? isRead}) => LetterNote(
        id: id,
        content: content,
        isRead: isRead ?? this.isRead,
        sentAt: sentAt,
        direction: direction,
      );
}

class ManittoPerson {
  const ManittoPerson({
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;
}

class ManittoChainLink {
  const ManittoChainLink({
    required this.manitto,
    required this.manitti,
  });

  final ManittoPerson manitto;
  final ManittoPerson manitti;
}

class PersonalReportData {
  const PersonalReportData({
    required this.status,
    required this.typeName,
    required this.storyText,
  });

  final ReportStatus status;
  final String typeName;
  final String storyText;
}

/// 임시 Mock 서비스.
///
/// TODO: 실제 백엔드 연동 시 이 클래스의 메서드 본문만 Repository/API 호출로 교체합니다.
/// API 스키마 기준: RoomDetail, Participant, Mission, TodayQuestion, Note, Results.
class MockGameService extends ChangeNotifier {
  MockGameService._();

  static final MockGameService instance = MockGameService._();
  final math.Random _random = math.Random();
  bool _isHydrating = false;
  bool _useMockData = true;

  bool get isHydrating => _isHydrating;
  bool get useMockData => _useMockData;

  String roomId = 'test-room-123';
  String roomName = '우당탕탕 디자인팀';
  String roomDescription = '서로 몰래 챙겨주는 따끈한 토마토 마니또 실험실';
  String inviteCode = 'TOMA25';
  int maxMissionCount = 3;
  bool isHost = true;
  DateTime endsAt = DateTime.now().add(const Duration(days: 3));

  GamePhase phase = GamePhase.preStart;

  final List<ParticipantProgress> participants = [
    ParticipantProgress(
      userId: 'user_001',
      displayName: '은효',
      missionCount: 2,
      isHost: true,
    ),
    ParticipantProgress(
      userId: 'user_002',
      displayName: '토마',
      missionCount: 3,
      isHost: false,
    ),
    ParticipantProgress(
      userId: 'user_003',
      displayName: '젤리',
      missionCount: 1,
      isHost: false,
    ),
    ParticipantProgress(
      userId: 'user_004',
      displayName: '콩떡',
      missionCount: 3,
      isHost: false,
    ),
  ];

  final List<EditableMission> myPreStartMissions = [
    const EditableMission(id: 'draft_1', content: '아침에 먼저 웃으며 인사하기'),
    const EditableMission(id: 'draft_2', content: '책상 위에 작은 간식 몰래 두기'),
  ];

  final List<String> _missionRecommendations = const [
    '마니띠가 좋아하는 음료수 몰래 사다주기',
    '하루에 한 번 진심 어린 칭찬 남기기',
    '힘들어 보이는 날 책상에 응원 쪽지 붙이기',
    '점심 메뉴 고를 때 은근히 취향 챙겨주기',
    '회의 끝나고 수고했다는 말 먼저 건네기',
    '귀여운 스티커나 작은 간식으로 비밀 응원하기',
  ];

  final MissionProvider inProgressMissions = MissionProvider.mock();

  TodayQuestionViewData todayQuestion = TodayQuestionViewData.mock();

  final List<QuestionHistoryViewData> questionHistory = [
    const QuestionHistoryViewData(
      date: '2026-05-25',
      question: '당신이 가장 좋아하는 겨울 간식은 무엇인가요?',
      myAnswer: null,
      manittoAnswer: '군고구마랑 동치미 조합이 최고입니다',
      isBlurred: true,
    ),
    const QuestionHistoryViewData(
      date: '2026-05-24',
      question: '요즘 들으면 힘나는 말은?',
      myAnswer: '오늘도 충분히 잘하고 있어!',
      manittoAnswer: '너 덕분에 팀 분위기가 말랑해졌어.',
      isBlurred: false,
    ),
    const QuestionHistoryViewData(
      date: '2026-05-23',
      question: '몰래 받으면 기분 좋은 선물은?',
      myAnswer: '귀여운 스티커랑 따뜻한 라떼',
      manittoAnswer: '손글씨 쪽지! 오래 간직할 수 있으니까.',
      isBlurred: false,
    ),
  ];

  final List<LetterNote> letters = [
    LetterNote(
      id: 'note_001',
      content: '오늘 발표 준비하느라 고생 많았어요. 내일은 제가 커피 요정이 될게요!',
      isRead: true,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      direction: NoteDirection.received,
    ),
    LetterNote(
      id: 'note_002',
      content: '책상 위 초코 쿠키는 비밀 토마토가 두고 갔습니다 :)',
      isRead: false,
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      direction: NoteDirection.received,
    ),
    LetterNote(
      id: 'note_003',
      content: '오늘도 파이팅! 지나가다 웃는 거 봤는데 덕분에 저도 힘났어요.',
      isRead: true,
      sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      direction: NoteDirection.sent,
    ),
  ];

  final ManittoPerson myManitto = const ManittoPerson(
    userId: 'user_002',
    displayName: '토마',
  );

  final List<ManittoChainLink> chain = const [
    ManittoChainLink(
      manitto: ManittoPerson(userId: 'user_001', displayName: '은효'),
      manitti: ManittoPerson(userId: 'user_002', displayName: '토마'),
    ),
    ManittoChainLink(
      manitto: ManittoPerson(userId: 'user_002', displayName: '토마'),
      manitti: ManittoPerson(userId: 'user_003', displayName: '젤리'),
    ),
    ManittoChainLink(
      manitto: ManittoPerson(userId: 'user_003', displayName: '젤리'),
      manitti: ManittoPerson(userId: 'user_004', displayName: '콩떡'),
    ),
    ManittoChainLink(
      manitto: ManittoPerson(userId: 'user_004', displayName: '콩떡'),
      manitti: ManittoPerson(userId: 'user_001', displayName: '은효'),
    ),
  ];

  final PersonalReportData personalReport = const PersonalReportData(
    status: ReportStatus.ready,
    typeName: '장난꾸러기 잠자리 요정',
    storyText:
        "저녁마다 '사랑스러운 내 친구'라 부르며 달콤한 꿈을 빌어주는 걸 보니, 당신은 마니띠에게 몰래 온기를 심어주는 잠자리 요정 같은 마니또였을 거예요.",
  );

  RoomStatus get roomStatus => switch (phase) {
        GamePhase.preStart => RoomStatus.waiting,
        GamePhase.inProgress => RoomStatus.inProgress,
        GamePhase.finished => RoomStatus.ended,
      };

  int get daysRemaining {
    final diff = endsAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  List<String> get participantNames =>
      participants.map((p) => p.displayName).toList(growable: false);

  Future<void> hydrateFromBackend(String roomId) async {
    if (_isHydrating) return;
    if (!DioClient.instance.isInitialized) return;

    _isHydrating = true;
    notifyListeners();

    try {
      final detailRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.room(roomId),
      );
      final detail = detailRes.data ?? const <String, dynamic>{};

      final participantsRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomParticipants(roomId),
      );
      final participantList =
          (participantsRes.data?['participants'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      final missionsRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomMissions(roomId),
      );
      final missionList =
          (missionsRes.data?['missions'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      final todayRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomQuestionsToday(roomId),
      );
      final historyRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomQuestionsHistory(roomId),
      );
      final historyList =
          (historyRes.data?['history'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      final sentRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomNotesSent(roomId),
      );
      final recvRes = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.roomNotesReceived(roomId),
      );

      _applyBackendData(
        detail: detail,
        participantsJson: participantList,
        missionsJson: missionList,
        todayQuestionJson: todayRes.data ?? const <String, dynamic>{},
        historyJson: historyList,
        sentNotesJson: (sentRes.data?['notes'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>(),
        receivedNotesJson:
            (recvRes.data?['notes'] as List<dynamic>? ?? const [])
                .cast<Map<String, dynamic>>(),
      );
      _useMockData = false;
    } on ApiException {
      _useMockData = true;
    } catch (_) {
      _useMockData = true;
    } finally {
      _isHydrating = false;
      notifyListeners();
    }
  }

  void _applyBackendData({
    required Map<String, dynamic> detail,
    required List<Map<String, dynamic>> participantsJson,
    required List<Map<String, dynamic>> missionsJson,
    required Map<String, dynamic> todayQuestionJson,
    required List<Map<String, dynamic>> historyJson,
    required List<Map<String, dynamic>> sentNotesJson,
    required List<Map<String, dynamic>> receivedNotesJson,
  }) {
    final status = RoomStatus.tryParse(detail['status'] as String?);
    if (status != null) {
      phase = switch (status) {
        RoomStatus.waiting => GamePhase.preStart,
        RoomStatus.inProgress => GamePhase.inProgress,
        RoomStatus.ended => GamePhase.finished,
      };
    }

    final name = detail['name'] as String?;
    if (name != null && name.trim().isNotEmpty) {
      roomName = name;
    }
    roomDescription = detail['description'] as String? ?? roomDescription;
    inviteCode = detail['inviteCode'] as String? ?? inviteCode;
    maxMissionCount = detail['missionCount'] as int? ?? maxMissionCount;
    isHost = detail['isHost'] as bool? ?? isHost;
    final endsAtRaw = detail['endsAt'] as String?;
    if (endsAtRaw != null && endsAtRaw.isNotEmpty) {
      try {
        endsAt = DateTime.parse(endsAtRaw).toLocal();
      } catch (_) {
        // keep existing mock value
      }
    }

    if (participantsJson.isNotEmpty) {
      participants
        ..clear()
        ..addAll(
          participantsJson.map(
            (item) => ParticipantProgress(
              userId: item['userId'] as String? ?? '',
              displayName: item['displayName'] as String? ?? '',
              missionCount: item['missionCount'] as int? ?? 0,
              isHost: item['isHost'] as bool? ?? false,
            ),
          ),
        );
    }

    if (missionsJson.isNotEmpty) {
      inProgressMissions.setMissions(
        missionsJson.map(MissionUiItem.fromApiJson).toList(),
      );
    }

    todayQuestion = TodayQuestionViewData.fromApiJson(todayQuestionJson);
    questionHistory
      ..clear()
      ..addAll(
        historyJson.map(
          (item) => QuestionHistoryViewData(
            date: item['date'] as String? ?? '',
            question: item['question'] as String? ?? '',
            myAnswer: item['myAnswer'] as String?,
            manittoAnswer: item['manitoAnswer'] as String?,
            isBlurred: item['isBlurred'] as bool? ?? false,
          ),
        ),
      );

    final sent = sentNotesJson.map(
      (json) => _noteFromJson(json, NoteDirection.sent),
    );
    final received = receivedNotesJson.map(
      (json) => _noteFromJson(json, NoteDirection.received),
    );
    letters
      ..clear()
      ..addAll(
          [...sent, ...received]..sort((a, b) => b.sentAt.compareTo(a.sentAt)));
  }

  LetterNote _noteFromJson(Map<String, dynamic> json, NoteDirection fallback) {
    final sentAtRaw = json['sentAt'] as String?;
    DateTime sentAt;
    try {
      sentAt = sentAtRaw == null ? DateTime.now() : DateTime.parse(sentAtRaw);
    } catch (_) {
      sentAt = DateTime.now();
    }

    return LetterNote(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      sentAt: sentAt,
      direction:
          NoteDirection.tryParse(json['direction'] as String?) ?? fallback,
    );
  }

  void startGame() {
    phase = GamePhase.inProgress;
    todayQuestion = todayQuestion.copyWithDebug(
      myAnswered: false,
      manittoAnswered: true,
    );
    notifyListeners();
  }

  void finishGame() {
    phase = GamePhase.finished;
    notifyListeners();
  }

  void resetToPreStart() {
    phase = GamePhase.preStart;
    notifyListeners();
  }

  String? addMyMission(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return '미션 내용을 입력해 주세요.';
    if (myPreStartMissions.length >= maxMissionCount) {
      return '미션은 최대 $maxMissionCount개까지 입력할 수 있어요.';
    }
    myPreStartMissions.add(
      EditableMission(
        id: 'draft_${DateTime.now().microsecondsSinceEpoch}',
        content: trimmed,
      ),
    );
    notifyListeners();
    return null;
  }

  String recommendMission() {
    final current = myPreStartMissions.map((m) => m.content).toSet();
    final candidates = _missionRecommendations
        .where((mission) => !current.contains(mission))
        .toList();
    final pool = candidates.isEmpty ? _missionRecommendations : candidates;
    return pool[_random.nextInt(pool.length)];
  }

  void updateMyMission(String id, String content) {
    final index = myPreStartMissions.indexWhere((m) => m.id == id);
    if (index < 0) return;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    myPreStartMissions[index] = myPreStartMissions[index].copyWith(
      content: trimmed,
    );
    notifyListeners();
  }

  void deleteMyMission(String id) {
    myPreStartMissions.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void sendLetter(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty || phase == GamePhase.finished) return;
    letters.insert(
      0,
      LetterNote(
        id: 'note_${DateTime.now().microsecondsSinceEpoch}',
        content: trimmed,
        isRead: true,
        sentAt: DateTime.now(),
        direction: NoteDirection.sent,
      ),
    );
    notifyListeners();
  }

  void submitTodayAnswer(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    todayQuestion = todayQuestion.copyWith(
      myAnswered: true,
      myAnswerContent: trimmed,
      manittoVisibleToMe: todayQuestion.manittoAnswered,
    );

    final index = questionHistory.indexWhere(
      (item) => item.date == todayQuestion.date,
    );
    final updated = QuestionHistoryViewData(
      date: todayQuestion.date,
      question: todayQuestion.content,
      myAnswer: trimmed,
      manittoAnswer: todayQuestion.manittoAnswerContent,
      isBlurred: false,
    );

    if (index >= 0) {
      questionHistory[index] = updated;
    } else {
      questionHistory.insert(0, updated);
    }

    notifyListeners();
  }

  void markLetterRead(String id) {
    final index = letters.indexWhere((note) => note.id == id);
    if (index < 0) return;
    letters[index] = letters[index].copyWith(isRead: true);
    notifyListeners();
  }
}
