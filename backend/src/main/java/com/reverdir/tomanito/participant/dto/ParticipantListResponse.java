package com.reverdir.tomanito.participant.dto;

import java.util.List;

public record ParticipantListResponse(
        List<ParticipantResponse> participants
) {
}
