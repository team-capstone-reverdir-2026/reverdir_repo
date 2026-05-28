class MissionApi {
  MissionApi._();

  static final List<Map<String, dynamic>> _missions = [];

  static Future<Map<String, dynamic>?> getMissions({
    required String roomId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'missions': _missions,
      'maxCount': 3,
    };
  }

  static Future<String?> getRandomMission() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final samples = [
      '아침에 먼저 인사하기',
      '커피나 간식 몰래 챙겨주기',
      '오늘 하루 응원 메시지 보내기',
      '마니띠가 좋아할 만한 칭찬 남기기',
    ];

    samples.shuffle();
    return samples.first;
  }

  static Future<Map<String, dynamic>?> createMission({
    required String roomId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mission = {
      'id': 'mission_${DateTime.now().millisecondsSinceEpoch}',
      'content': content,
      'isCompleted': false,
    };

    _missions.add(mission);
    return mission;
  }

  static Future<Map<String, dynamic>?> updateMission({
    required String roomId,
    required String missionId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _missions.indexWhere((m) => m['id'] == missionId);
    if (index == -1) return null;

    _missions[index]['content'] = content;
    return _missions[index];
  }

  static Future<bool> deleteMission({
    required String roomId,
    required String missionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _missions.removeWhere((m) => m['id'] == missionId);
    return true;
  }
}