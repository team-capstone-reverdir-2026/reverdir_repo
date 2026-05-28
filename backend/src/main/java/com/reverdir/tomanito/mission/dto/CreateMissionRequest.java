package com.reverdir.tomanito.mission.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateMissionRequest(
        @NotBlank
        @Size(max = 200)
        String content
) {
}
