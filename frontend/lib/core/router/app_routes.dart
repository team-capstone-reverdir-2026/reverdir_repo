/// 앱 내부 경로 상수 (doc/api-docs.json 기능 흐름 기준).
class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';

  // ── Home / Rooms ──────────────────────────────────────────────────────────
  /// GET /rooms — 참여 중인 방 목록
  static const String home = '/home';

  static const String roomCreate = '/room/create';
  static const String roomJoin = '/room/join';
  static const String roomJoinProfile = '/room/join/profile';
  static const String roomJoinMissions = '/room/join/missions';

  /// 방 상세·대기·메인 (path param)
  static const String roomDetail = '/room/:roomId';

  // ── Room sub-features ─────────────────────────────────────────────────────
  static const String roomMissions = '/room/:roomId/missions';
  static const String roomNotes = '/room/:roomId/notes';
  static const String roomLetterSend = '/room/:roomId/notes/send';
  static const String roomHints = '/room/:roomId/hints';
  static const String roomResults = '/room/:roomId/results';
  static const String roomDemo = '/room/:roomId/demo-admin';

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String roomDetailPath(String roomId) => '/room/$roomId';

  static String roomJoinProfilePath({
    required String roomId,
    required String invitationCode,
    required int missionCount,
  }) =>
      '$roomJoinProfile?roomId=${Uri.encodeComponent(roomId)}'
      '&code=${Uri.encodeComponent(invitationCode)}'
      '&missionCount=$missionCount';

  static String roomJoinMissionsPath({
    required String roomId,
    required int missionCount,
    required String userName,
  }) =>
      '$roomJoinMissions?roomId=${Uri.encodeComponent(roomId)}'
      '&missionCount=$missionCount'
      '&userName=${Uri.encodeComponent(userName)}';

  static String roomMissionsPath(String roomId) => '/room/$roomId/missions';

  static String roomNotesPath(String roomId) => '/room/$roomId/notes';

  static String roomLetterSendPath(String roomId) => '/room/$roomId/notes/send';

  static String roomHintsPath(String roomId) => '/room/$roomId/hints';

  static String roomResultsPath(String roomId) => '/room/$roomId/results';

  static String roomDemoPath(String roomId) => '/room/$roomId/demo-admin';
}
