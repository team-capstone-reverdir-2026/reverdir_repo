package com.reverdir.tomanito.question.dto;

public record ManitoAnswerDto(
        boolean answered,
        boolean visibleToMe,
        String content
) {
    public static ManitoAnswerDto notAnswered() {
        return new ManitoAnswerDto(false, false, null);
    }

    public static ManitoAnswerDto hidden(boolean manitoAnswered) {
        return new ManitoAnswerDto(manitoAnswered, false, null);
    }

    public static ManitoAnswerDto visible(String content) {
        return new ManitoAnswerDto(true, true, content);
    }
}
