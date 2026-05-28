package com.reverdir.tomanito.auth.dto;

import com.reverdir.tomanito.user.domain.User;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        UserProfile user
) {
    public static AuthResponse of(String accessToken, String refreshToken, User user) {
        return new AuthResponse(accessToken, refreshToken, UserProfile.from(user));
    }
}
