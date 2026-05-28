package com.reverdir.tomanito.room.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.OffsetDateTime;

public record CreateRoomRequest(
        @NotBlank
        String name,

        String description,

        @NotNull
        OffsetDateTime endsAt,

        @NotNull
        @Min(1)
        @Max(10)
        Integer missionCount
) {
}
