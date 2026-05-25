package com.reverdir.tomanito.room.dto;

import com.reverdir.tomanito.room.domain.Room;

public record RoomJoinPreview(
        String roomId,
        String name,
        String description,
        int missionCount,
        int participantCount
) {
    public static RoomJoinPreview from(Room room, long participantCount) {
        return new RoomJoinPreview(
                String.valueOf(room.getId()),
                room.getName(),
                room.getDescription(),
                room.getMissionCount(),
                (int) participantCount
        );
    }
}
