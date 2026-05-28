package com.reverdir.tomanito.room.dto;

import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;

public record RoomSummary(
        String id,
        String name,
        RoomStatus status,
        int participantCount
) {
    public static RoomSummary from(Room room, long participantCount) {
        return new RoomSummary(
                String.valueOf(room.getId()),
                room.getName(),
                room.getStatus(),
                (int) participantCount
        );
    }
}
