package com.reverdir.tomanito.question.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SubmitAnswerRequest(
        @NotBlank
        @Size(max = 500)
        String content
) {
}
