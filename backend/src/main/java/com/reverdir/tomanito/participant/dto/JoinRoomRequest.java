package com.reverdir.tomanito.participant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record JoinRoomRequest(
        @NotBlank
        @Size(max = 20)
        String displayName
) {
}
