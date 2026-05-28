enum RoomStatus {
  waiting,
  active,
  finished,
}

extension RoomStatusX on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.waiting:
        return '대기중';
      case RoomStatus.active:
        return '진행중';
      case RoomStatus.finished:
        return '종료';
    }
  }
}