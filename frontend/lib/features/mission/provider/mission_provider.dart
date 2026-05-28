import 'package:flutter/foundation.dart';

import '../../../core/utils/json_parse.dart';

/// GET /rooms/{roomId}/missions — Mission UI 항목
class MissionUiItem {
  const MissionUiItem({
    required this.id,
    required this.content,
    this.isCompleted = false,
  });

  final String id;
  final String content;
  final bool isCompleted;

  MissionUiItem copyWith({bool? isCompleted}) => MissionUiItem(
        id: id,
        content: content,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  factory MissionUiItem.fromApiJson(Map<String, dynamic> json) => MissionUiItem(
        id: parseJsonString(json['id']),
        content: parseJsonString(json['content']),
        isCompleted: parseJsonBool(json['isCompleted']),
      );
}

/// PATCH /rooms/{roomId}/missions/{missionId} — isCompleted 토글.
///
/// TODO: [MissionRepository.patchMission] API 연동
class MissionProvider extends ChangeNotifier {
  MissionProvider(
    List<MissionUiItem> initial, {
    Future<void> Function(String missionId, bool isCompleted)? onToggleRemote,
  })  : _missions = List.of(initial),
        _onToggleRemote = onToggleRemote;

  factory MissionProvider.empty() => MissionProvider(const []);

  List<MissionUiItem> _missions;
  final Future<void> Function(String missionId, bool isCompleted)? _onToggleRemote;
  List<MissionUiItem> get missions => List.unmodifiable(_missions);

  Future<void> toggleMission(String missionId) async {
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index < 0) return;

    final next = !_missions[index].isCompleted;
    _missions[index] = _missions[index].copyWith(
      isCompleted: next,
    );
    notifyListeners();

    try {
      await _onToggleRemote?.call(missionId, next);
    } catch (_) {
      _missions[index] = _missions[index].copyWith(
        isCompleted: !next,
      );
      notifyListeners();
      rethrow;
    }
  }

  void setMissions(List<MissionUiItem> items) {
    _missions = List.of(items);
    notifyListeners();
  }
}
