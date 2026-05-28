package com.reverdir.tomanito.mission.dto;

import jakarta.validation.constraints.Size;

public record UpdateMissionRequest(
        @Size(max = 200)
        String content,

        Boolean isCompleted
) {
}
