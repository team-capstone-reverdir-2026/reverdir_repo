package com.reverdir.tomanito.global.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    VALIDATION_ERROR(404, "입력값이 올바르지 않습니다!"),
    DUPLICATE_USERNAME(409, "이미 사용 중인 아이디입니다!"),
    INVALID_CREDENTIALS(401, "아이디 또는 비밀번호가 올바르지 않습니다!"),
    UNAUTHORIZED(401,"인증이 필요합니다!"),
    INVALID_INVITE_CODE(404,"유효하지 않은 초대 코드입니다!"),
    ALREADY_JOINED(409,"이미 참여중인 방입니다!"),
    FORBIDDEN(403, "접근 권한이 없습니다!"),
    NOT_FOUND(404, "요청한 리소스를 찾을 수 없습니다!"),
    GAME_ALREADY_STARTED(400,"이미 게임이 시작된 방에는 입장할 수 없습니다!"),
    MISSION_LIMIT_EXCEEDED(400,"미션의 최대 개수를 넘었습니다!"),
    NOT_ENOUGH_PARTICIPANTS(400,"게임 시작을 위한 참여자 수가 부족합니다!"),
    NOT_ENOUGH_MISSION(400, "미션이 모두 입력되지 않았습니다!"),
    NOT_HOST(403,"방장만 게임을 시작할 수 있습니다!"),
    GAME_ENDED(400,"게임이 종료되었습니다!."),
    GAME_NOT_ENDED(400,"게임이 아직 종료되지 않았습니다!"),
    INTERNAL_SERVER_ERROR(500, "서버 내부 오류입니다.");

    private final int statusCode;
    private final String message;
}
