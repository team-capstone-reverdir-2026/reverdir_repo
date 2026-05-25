package com.reverdir.tomanito.room.dto;

import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;

import java.time.OffsetDateTime;

public record RoomDetail(
        String id,
        String name,
        String description,
        RoomStatus status,
        String inviteCode,
        OffsetDateTime endsAt,
        int missionCount,
        int participantCount,
        int daysRemaining,
        boolean isHost
) {
    public static RoomDetail from(Room room, long participantCount, int daysRemaining, boolean isHost) {
        return new RoomDetail(
                String.valueOf(room.getId()),
                room.getName(),
                room.getDescription(),
                room.getStatus(),
                isHost ? room.getInviteCode() : null,
                room.getEndsAt(),
                room.getMissionCount(),
                (int) participantCount,
                daysRemaining,
                isHost
        );
    }
}
