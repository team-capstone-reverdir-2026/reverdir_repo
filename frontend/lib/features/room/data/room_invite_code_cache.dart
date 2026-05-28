/// 방별 초대 코드 — API가 방장에게만 내려줄 때 참가자 화면용 로컬 보관.
class RoomInviteCodeCache {
  RoomInviteCodeCache._();

  static final Map<String, String> _codes = {};

  static void save(String roomId, String inviteCode) {
    final id = roomId.trim();
    final code = inviteCode.trim().toUpperCase();
    if (id.isEmpty || code.isEmpty) return;
    _codes[id] = code;
  }

  static String? read(String roomId) {
    final code = _codes[roomId.trim()];
    if (code == null || code.isEmpty) return null;
    return code;
  }

  static String resolve({
    required String roomId,
    String? fromApi,
    String? fromQuery,
  }) {
    final api = fromApi?.trim();
    if (api != null && api.isNotEmpty) return api.toUpperCase();

    final query = fromQuery?.trim();
    if (query != null && query.isNotEmpty) {
      final upper = query.toUpperCase();
      save(roomId, upper);
      return upper;
    }

    return read(roomId) ?? '';
  }
}
