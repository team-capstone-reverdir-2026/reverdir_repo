class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:8080/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';

  // Rooms
  static const String rooms = '/rooms';
  static const String joinRoom = '/rooms/join';

  static String roomDetail(String roomId) {
    return '/rooms/$roomId';
  }

  // Participants
  static String roomParticipants(String roomId) {
    return '/rooms/$roomId/participants';
  }

  // Missions
  static const String randomMission = '/missions/random';

  static String roomMissions(String roomId) {
    return '/rooms/$roomId/missions';
  }

  static String roomMissionDetail(String roomId, String missionId) {
    return '/rooms/$roomId/missions/$missionId';
  }
}
