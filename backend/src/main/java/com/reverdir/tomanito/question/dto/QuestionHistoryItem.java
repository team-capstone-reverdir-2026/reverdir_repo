package com.reverdir.tomanito.question.dto;

import java.time.LocalDate;

public record QuestionHistoryItem(
        LocalDate date,
        String question,
        String myAnswer,
        String manitoAnswer,
        boolean isBlurred
) {
}
