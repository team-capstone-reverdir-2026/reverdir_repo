package com.reverdir.tomanito.global.error;

public record ErrorResponse(
        String code,
        String message
) {
    public static ErrorResponse from(ErrorCode errorCode) {
        return new ErrorResponse(errorCode.toString(), errorCode.getMessage());
    }
}
