import 'package:flutter/foundation.dart';

import '../../../core/network/api_enums.dart';
import '../../../core/network/error_handler.dart';
import '../../hint/provider/hint_provider.dart';
import '../../mission/provider/mission_provider.dart';

/// GameMainScreen 본문 상태.
enum GameMainBodyState { loading, error, ready }

/// GET /rooms/{roomId} + questions/today + missions 조합.
///
/// TODO: [GameRepository]·[HintRepository]·[MissionRepository] 연동
class GameProvider extends ChangeNotifier {
  GameMainBodyState _bodyState = GameMainBodyState.loading;
  GameMainBodyState get bodyState => _bodyState;

  ApiException? _error;
  ApiException? get error => _error;

  String roomName = '';
  RoomStatus roomStatus = RoomStatus.inProgress;
  int daysRemaining = 0;
  String? myManittiName;
  TodayQuestionViewData? todayQuestion;
  MissionProvider? missionProvider;
  List<String> participantNames = [];

  bool get isLoading => _bodyState == GameMainBodyState.loading;
  bool get hasError => _bodyState == GameMainBodyState.error;

  /// TODO: roomId로 API 병렬 fetch
  Future<void> loadRoom(String roomId) async {
    _bodyState = GameMainBodyState.loading;
    _error = null;
    notifyListeners();

    try {
      // TODO: final detail = await gameRepository.fetchRoomDetail(roomId);
      _applyMockData(roomId);
      _bodyState = GameMainBodyState.ready;
    } on ApiException catch (e) {
      _error = e;
      _bodyState = GameMainBodyState.error;
    } catch (e) {
      _error = ApiException(
        code: ErrorCode.unknown,
        message: e.toString(),
      );
      _bodyState = GameMainBodyState.error;
    }
    notifyListeners();
  }

  void _applyMockData(String roomId) {
    roomName = '우당탕탕 디자인팀';
    roomStatus = RoomStatus.inProgress;
    daysRemaining = 3;
    myManittiName = null;
    participantNames = ['홍길동', '김철수', '이영희', '박민수', '최지우'];
    todayQuestion = TodayQuestionViewData.mock();
    missionProvider = MissionProvider.mock();
  }

  /// GameMainScreen debug 플래그로 UI만 덮어쓰기
  void applyDebugQuestionFlags({
    required bool myAnswered,
    required bool manittoAnswered,
  }) {
    final base = todayQuestion;
    if (base == null) return;
    todayQuestion = base.copyWithDebug(
      myAnswered: myAnswered,
      manittoAnswered: manittoAnswered,
    );
    notifyListeners();
  }
}
