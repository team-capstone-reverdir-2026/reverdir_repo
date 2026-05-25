package com.reverdir.tomanito.result.dto;

import com.reverdir.tomanito.participant.domain.Participant;

public record ParticipantSummary(
        String userId,
        String displayName
) {
    public static ParticipantSummary from(Participant participant) {
        return new ParticipantSummary(
                String.valueOf(participant.getUser().getId()),
                participant.getDisplayName()
        );
    }
}
