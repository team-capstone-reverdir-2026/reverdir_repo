import 'package:flutter/foundation.dart';

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
        id: json['id'] as String? ?? '',
        content: json['content'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

/// PATCH /rooms/{roomId}/missions/{missionId} — isCompleted 토글.
///
/// TODO: [MissionRepository.patchMission] API 연동
class MissionProvider extends ChangeNotifier {
  MissionProvider(List<MissionUiItem> initial) : _missions = List.of(initial);

  factory MissionProvider.empty() => MissionProvider(const []);

  factory MissionProvider.mock() => MissionProvider(const [
        MissionUiItem(
          id: 'm1',
          content: '아침에 만나면 윙크하며 인사하기',
          isCompleted: true,
        ),
        MissionUiItem(
          id: 'm2',
          content: '커피나 간식 몰래 책상에 올려두기',
        ),
        MissionUiItem(
          id: 'm3',
          content: '칭찬 한 마디 건네기',
        ),
      ]);

  List<MissionUiItem> _missions;
  List<MissionUiItem> get missions => List.unmodifiable(_missions);

  void toggleMission(String missionId) {
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index < 0) return;

    _missions[index] = _missions[index].copyWith(
      isCompleted: !_missions[index].isCompleted,
    );
    notifyListeners();

    // TODO: missionRepository.patchMission(roomId, missionId, isCompleted: ...)
  }

  void setMissions(List<MissionUiItem> items) {
    _missions = List.of(items);
    notifyListeners();
  }
}
