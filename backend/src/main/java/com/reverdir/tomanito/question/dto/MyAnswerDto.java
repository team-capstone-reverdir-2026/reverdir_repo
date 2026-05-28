package com.reverdir.tomanito.question.dto;

public record MyAnswerDto(
        boolean answered,
        String content
) {
    public static MyAnswerDto notAnswered() {
        return new MyAnswerDto(false, null);
    }

    public static MyAnswerDto of(String content) {
        return new MyAnswerDto(true, content);
    }
}
