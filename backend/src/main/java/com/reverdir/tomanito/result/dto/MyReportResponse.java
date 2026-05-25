package com.reverdir.tomanito.result.dto;

public record MyReportResponse(
        String status,
        String typeName,
        String typeImageUrl,
        String storyText
) {
}
