package com.reverdir.tomanito.question.dto;

import java.util.List;

public record QuestionHistoryResponse(
        List<QuestionHistoryItem> history
) {
}
