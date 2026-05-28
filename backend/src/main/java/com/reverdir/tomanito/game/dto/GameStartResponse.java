package com.reverdir.tomanito.game.dto;

import com.reverdir.tomanito.room.domain.RoomStatus;

import java.time.OffsetDateTime;

public record GameStartResponse(
        RoomStatus status,
        OffsetDateTime startedAt
) {
}
