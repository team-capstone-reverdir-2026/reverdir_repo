package com.reverdir.tomanito.note.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SendNoteRequest(
        @NotBlank
        @Size(max = 1000)
        String content
) {
}
