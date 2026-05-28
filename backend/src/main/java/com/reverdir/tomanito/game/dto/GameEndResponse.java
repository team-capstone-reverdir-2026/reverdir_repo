package com.reverdir.tomanito.game.dto;

import com.reverdir.tomanito.room.domain.RoomStatus;

import java.time.OffsetDateTime;

public record GameEndResponse(
        RoomStatus status,
        OffsetDateTime endedAt
) {
}
