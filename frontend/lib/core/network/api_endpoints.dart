/// doc/api-docs.json paths·servers 상수.
///
/// [ApiClient]는 Base URL + 아래 상대 경로만 사용합니다.
/// 경로 파라미터가 있는 API는 헬퍼 메서드로 조합합니다.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Servers (openapi servers[]) ─────────────────────────────────────────
  static const String productionBaseUrl = 'https://api.manitto.app/v1';
  static const String developmentBaseUrl = 'https://dev-api.manitto.app/v1';
  static const String localBaseUrl = 'http://localhost:8080/v1';

  /// 앱 기본 Base URL (Production)
  static const String baseUrl = productionBaseUrl;

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // ── Rooms ───────────────────────────────────────────────────────────────
  static const String rooms = '/rooms';
  static const String roomsJoin = '/rooms/join';

  static String room(String roomId) => '/rooms/$roomId';

  // ── Participants ────────────────────────────────────────────────────────
  static String roomParticipants(String roomId) =>
      '/rooms/$roomId/participants';

  // ── Missions ────────────────────────────────────────────────────────────
  static String roomMissions(String roomId) => '/rooms/$roomId/missions';

  static String roomMission(String roomId, String missionId) =>
      '/rooms/$roomId/missions/$missionId';

  static const String missionsRandom = '/missions/random';

  // ── Game ────────────────────────────────────────────────────────────────
  static String roomGameStart(String roomId) => '/rooms/$roomId/game/start';

  static String roomGameEnd(String roomId) => '/rooms/$roomId/game/end';

  static String roomMyManitti(String roomId) => '/rooms/$roomId/my-manitti';

  // ── DailyQuestions ──────────────────────────────────────────────────────
  static String roomQuestionsToday(String roomId) =>
      '/rooms/$roomId/questions/today';

  static String roomQuestionsTodayAnswer(String roomId) =>
      '/rooms/$roomId/questions/today/answer';

  static String roomQuestionsHistory(String roomId) =>
      '/rooms/$roomId/questions/history';

  // ── Notes ───────────────────────────────────────────────────────────────
  static String roomNotes(String roomId) => '/rooms/$roomId/notes';

  static String roomNotesSent(String roomId) => '/rooms/$roomId/notes/sent';

  static String roomNotesReceived(String roomId) =>
      '/rooms/$roomId/notes/received';

  static String roomNoteRead(String roomId, String noteId) =>
      '/rooms/$roomId/notes/$noteId/read';

  // ── Results ─────────────────────────────────────────────────────────────
  static String roomResultsManittoReveal(String roomId) =>
      '/rooms/$roomId/results/manitto-reveal';

  static String roomResultsMyReport(String roomId) =>
      '/rooms/$roomId/results/my-report';

  /// JWT 불필요 — [AuthInterceptor]가 Authorization 헤더를 붙이지 않음
  static bool isPublicPath(String path) {
    return path == authRegister ||
        path == authLogin ||
        path == authRefresh;
  }
}
