package com.reverdir.tomanito.mission.dto;

import java.util.List;

public record MissionListResponse(
        List<MissionResponse> missions,
        int maxCount
) {
}
