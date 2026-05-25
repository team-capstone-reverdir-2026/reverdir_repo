package com.reverdir.tomanito.mission.dto;

import com.reverdir.tomanito.mission.domain.Mission;

import java.time.LocalDateTime;

public record MissionResponse(
        String id,
        String content,
        boolean isCompleted,
        LocalDateTime createdAt
) {
    public static MissionResponse from(Mission mission) {
        return new MissionResponse(
                String.valueOf(mission.getId()),
                mission.getContent(),
                mission.isCompleted(),
                mission.getCreatedAt()
        );
    }
}
