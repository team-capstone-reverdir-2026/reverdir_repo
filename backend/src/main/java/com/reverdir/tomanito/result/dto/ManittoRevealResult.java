package com.reverdir.tomanito.result.dto;

import java.util.List;

public record ManittoRevealResult(
        ParticipantSummary myManitto,
        List<ManittoChainItem> chain
) {
}
