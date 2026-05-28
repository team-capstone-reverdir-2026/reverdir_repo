package com.reverdir.tomanito.room.dto;

import java.util.List;

public record RoomListResponse(
        List<RoomSummary> rooms
) {
}
