package com.reverdir.tomanito.question.dto;

import com.reverdir.tomanito.question.domain.Answer;

import java.time.LocalDateTime;

public record AnswerResponse(
        String id,
        String questionId,
        String content,
        LocalDateTime createdAt
) {
    public static AnswerResponse from(Answer answer) {
        return new AnswerResponse(
                String.valueOf(answer.getId()),
                String.valueOf(answer.getQuestion().getId()),
                answer.getContent(),
                answer.getCreatedAt()
        );
    }
}
