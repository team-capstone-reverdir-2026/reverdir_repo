package com.reverdir.tomanito.participant.dto;

import com.reverdir.tomanito.participant.domain.Participant;

public record ParticipantResponse(
        String userId,
        String displayName,
        int missionCount,
        boolean isHost
) {
    public static ParticipantResponse from(Participant participant, long missionCount) {
        return new ParticipantResponse(
                String.valueOf(participant.getUser().getId()),
                participant.getDisplayName(),
                (int) missionCount,
                participant.isHost()
        );
    }
}
