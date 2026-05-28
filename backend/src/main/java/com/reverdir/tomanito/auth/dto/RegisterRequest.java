package com.reverdir.tomanito.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank
        @Size(max = 19)
        String name,

        @NotBlank
        @Size(min = 4, max = 19)
        String username,

        @NotBlank
        @Size(min = 4, max = 19)
        String password
) {
}
