import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_enums.dart';

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
        id: json['id'] as String? ?? '',
        content: json['content'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
        direction:
            NoteDirection.tryParse(json['direction'] as String?) ?? NoteDirection.sent,
      );
}

class LetterRepository {
  const LetterRepository({ApiClient? client}) : _client = client;
  final ApiClient? _client;
  ApiClient get _api => _client ?? apiClient;

  Future<List<LetterNoteData>> fetchSent(String roomId) async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.roomNotesSent(roomId));
    final list = (res.data?['notes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return list.map(LetterNoteData.fromJson).toList();
  }

  Future<List<LetterNoteData>> fetchReceived(String roomId) async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.roomNotesReceived(roomId));
    final list = (res.data?['notes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return list.map(LetterNoteData.fromJson).toList();
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

