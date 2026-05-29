import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';
import '../../../core/utils/json_parse.dart';

class LetterNoteData {
  const LetterNoteData({
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

  factory LetterNoteData.fromJson(Map<String, dynamic> json) => LetterNoteData(
        id: parseJsonString(json['id']),
        content: parseJsonString(json['content']),
        isRead: parseJsonBool(json['isRead']),
        sentAt: DateTime.tryParse(parseJsonString(json['sentAt'])) ??
            DateTime.now(),
        direction: NoteDirection.tryParse(parseJsonString(json['direction'])) ??
            NoteDirection.sent,
      );
}

class LetterRepository {
  const LetterRepository({ApiClient? client}) : _client = client;
  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  Future<List<LetterNoteData>> fetchSent(
    String roomId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomNotesSent(roomId),
      queryParameters: _dateQuery(from, to),
    );
    final list = parseJsonMapList(res.data?['notes']);
    return list.map(LetterNoteData.fromJson).toList();
  }

  Future<List<LetterNoteData>> fetchReceived(
    String roomId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.roomNotesReceived(roomId),
      queryParameters: _dateQuery(from, to),
    );
    final list = parseJsonMapList(res.data?['notes']);
    return list.map(LetterNoteData.fromJson).toList();
  }

  /// api-docs: `from`/`to` = `YYYY-MM-DD` (필터 선택 시에만 전달).
  static Map<String, dynamic>? _dateQuery(DateTime? from, DateTime? to) {
    if (from == null && to == null) return null;
    return {
      if (from != null) 'from': _toApiDate(from),
      if (to != null) 'to': _toApiDate(to),
    };
  }

  static String _toApiDate(DateTime date) {
    final local = date.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> markRead(String roomId, String noteId) async {
    await _api.patch<Map<String, dynamic>>(ApiEndpoints.roomNoteRead(roomId, noteId));
  }

  Future<void> send(String roomId, String content) async {
    await _api.post<Map<String, dynamic>>(
      ApiEndpoints.roomNotes(roomId),
      data: {'content': content},
    );
  }
}

