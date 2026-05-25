package com.reverdir.tomanito.room.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RoomJoinRequest(
        @NotBlank
        @Size(min = 6, max = 6)
        String inviteCode
) {
}
