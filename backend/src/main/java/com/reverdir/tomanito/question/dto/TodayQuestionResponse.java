package com.reverdir.tomanito.question.dto;

import com.reverdir.tomanito.question.domain.Question;

import java.time.LocalDate;

public record TodayQuestionResponse(
        String questionId,
        String content,
        LocalDate date,
        MyAnswerDto myAnswer,
        ManitoAnswerDto manitoAnswer
) {
    public static TodayQuestionResponse of(
            Question question,
            MyAnswerDto myAnswer,
            ManitoAnswerDto manitoAnswer
    ) {
        return new TodayQuestionResponse(
                String.valueOf(question.getId()),
                question.getContent(),
                question.getQuestionDate(),
                myAnswer,
                manitoAnswer
        );
    }
}
