package com.reverdir.tomanito.room.dto;

import com.reverdir.tomanito.room.domain.Room;

import java.time.OffsetDateTime;

public record CreateRoomResponse(
        String roomId,
        String inviteCode,
        String name,
        String description,
        OffsetDateTime endsAt,
        int missionCount
) {
    public static CreateRoomResponse from(Room room) {
        return new CreateRoomResponse(
                String.valueOf(room.getId()),
                room.getInviteCode(),
                room.getName(),
                room.getDescription(),
                room.getEndsAt(),
                room.getMissionCount()
        );
    }
}
