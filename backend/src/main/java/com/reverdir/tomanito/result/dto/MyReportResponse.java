package com.reverdir.tomanito.result.dto;

import lombok.Builder;

@Builder
public record MyReportResponse(
        String status,
        String typeName,
        String typeImageUrl,
        String storyText
) {
}
