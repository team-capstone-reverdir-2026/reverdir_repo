/// doc/api-docs.json 공통 enum·에러 코드.
///
/// Feature·Theme·ErrorHandler는 이 파일만 참조합니다.

// ═══════════════════════════════════════════════════════════════════════════
// 도메인 상태 (components/schemas)
// ═══════════════════════════════════════════════════════════════════════════

/// RoomStatus — WAITING | IN_PROGRESS | ENDED
enum RoomStatus {
  waiting,
  inProgress,
  ended;

  static RoomStatus? tryParse(String? raw) {
    switch (raw) {
      case 'WAITING':
        return RoomStatus.waiting;
      case 'IN_PROGRESS':
        return RoomStatus.inProgress;
      case 'ENDED':
        return RoomStatus.ended;
      default:
        return null;
    }
  }

  String get wireValue => switch (this) {
        RoomStatus.waiting => 'WAITING',
        RoomStatus.inProgress => 'IN_PROGRESS',
        RoomStatus.ended => 'ENDED',
      };

  String get displayLabel => switch (this) {
        RoomStatus.waiting => '기다리는 중…',
        RoomStatus.inProgress => '진행 중',
        RoomStatus.ended => '종료',
      };
}

/// MyReport.status — PENDING | READY
enum ReportStatus {
  pending,
  ready;

  static ReportStatus? tryParse(String? raw) {
    switch (raw) {
      case 'PENDING':
        return ReportStatus.pending;
      case 'READY':
        return ReportStatus.ready;
      default:
        return null;
    }
  }

  String get wireValue => switch (this) {
        ReportStatus.pending => 'PENDING',
        ReportStatus.ready => 'READY',
      };

  String get displayLabel => switch (this) {
        ReportStatus.pending => '분석 중…',
        ReportStatus.ready => '결과 준비됨',
      };
}

/// Note.direction — SENT | RECEIVED
enum NoteDirection {
  sent,
  received;

  static NoteDirection? tryParse(String? raw) {
    switch (raw) {
      case 'SENT':
        return NoteDirection.sent;
      case 'RECEIVED':
        return NoteDirection.received;
      default:
        return null;
    }
  }

  String get wireValue => switch (this) {
        NoteDirection.sent => 'SENT',
        NoteDirection.received => 'RECEIVED',
      };

  String get displayLabel => switch (this) {
        NoteDirection.sent => '보낸 쪽지',
        NoteDirection.received => '받은 쪽지',
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// ErrorResponse.code (api-docs examples + 공통 responses)
// ═══════════════════════════════════════════════════════════════════════════

/// ErrorResponse.code — 대문자 스네이크케이스
enum ErrorCode {
  duplicateUsername,
  invalidCredentials,
  invalidInviteCode,
  alreadyJoined,
  gameAlreadyStarted,
  missionLimitExceeded,
  notEnoughParticipants,
  notHost,
  gameEnded,
  gameNotEnded,
  validationError,
  unauthorized,
  forbidden,
  notFound,
  unknown;

  static ErrorCode tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return ErrorCode.unknown;
    switch (raw) {
      case 'DUPLICATE_USERNAME':
        return ErrorCode.duplicateUsername;
      case 'INVALID_CREDENTIALS':
        return ErrorCode.invalidCredentials;
      case 'INVALID_INVITE_CODE':
        return ErrorCode.invalidInviteCode;
      case 'ALREADY_JOINED':
        return ErrorCode.alreadyJoined;
      case 'GAME_ALREADY_STARTED':
        return ErrorCode.gameAlreadyStarted;
      case 'MISSION_LIMIT_EXCEEDED':
        return ErrorCode.missionLimitExceeded;
      case 'NOT_ENOUGH_PARTICIPANTS':
        return ErrorCode.notEnoughParticipants;
      case 'NOT_HOST':
        return ErrorCode.notHost;
      case 'GAME_ENDED':
        return ErrorCode.gameEnded;
      case 'GAME_NOT_ENDED':
        return ErrorCode.gameNotEnded;
      case 'VALIDATION_ERROR':
        return ErrorCode.validationError;
      case 'UNAUTHORIZED':
        return ErrorCode.unauthorized;
      case 'FORBIDDEN':
        return ErrorCode.forbidden;
      case 'NOT_FOUND':
        return ErrorCode.notFound;
      default:
        return ErrorCode.unknown;
    }
  }

  String get wireValue => switch (this) {
        ErrorCode.duplicateUsername => 'DUPLICATE_USERNAME',
        ErrorCode.invalidCredentials => 'INVALID_CREDENTIALS',
        ErrorCode.invalidInviteCode => 'INVALID_INVITE_CODE',
        ErrorCode.alreadyJoined => 'ALREADY_JOINED',
        ErrorCode.gameAlreadyStarted => 'GAME_ALREADY_STARTED',
        ErrorCode.missionLimitExceeded => 'MISSION_LIMIT_EXCEEDED',
        ErrorCode.notEnoughParticipants => 'NOT_ENOUGH_PARTICIPANTS',
        ErrorCode.notHost => 'NOT_HOST',
        ErrorCode.gameEnded => 'GAME_ENDED',
        ErrorCode.gameNotEnded => 'GAME_NOT_ENDED',
        ErrorCode.validationError => 'VALIDATION_ERROR',
        ErrorCode.unauthorized => 'UNAUTHORIZED',
        ErrorCode.forbidden => 'FORBIDDEN',
        ErrorCode.notFound => 'NOT_FOUND',
        ErrorCode.unknown => 'UNKNOWN',
      };

  /// 서버 message 없을 때 UI 폴백
  String get displayLabel => switch (this) {
        ErrorCode.duplicateUsername => '이미 사용 중인 아이디입니다.',
        ErrorCode.invalidCredentials => '아이디 또는 비밀번호가 올바르지 않습니다.',
        ErrorCode.invalidInviteCode => '유효하지 않은 초대 코드입니다.',
        ErrorCode.alreadyJoined => '이미 참여 중인 방입니다.',
        ErrorCode.gameAlreadyStarted => '이미 게임이 시작된 방에는 입장할 수 없습니다.',
        ErrorCode.missionLimitExceeded => '미션은 최대 개수까지 입력할 수 있습니다.',
        ErrorCode.notEnoughParticipants =>
          '게임 시작을 위해 최소 2명의 참여자가 필요합니다.',
        ErrorCode.notHost => '방장만 게임을 시작할 수 있습니다.',
        ErrorCode.gameEnded => '게임이 종료되어 쪽지를 보낼 수 없습니다.',
        ErrorCode.gameNotEnded => '게임이 종료된 후에 결과를 확인할 수 있습니다.',
        ErrorCode.validationError => '입력값이 올바르지 않습니다.',
        ErrorCode.unauthorized => '인증이 필요합니다.',
        ErrorCode.forbidden => '접근 권한이 없습니다.',
        ErrorCode.notFound => '요청한 리소스를 찾을 수 없습니다.',
        ErrorCode.unknown => '알 수 없는 오류가 발생했습니다.',
      };
}
