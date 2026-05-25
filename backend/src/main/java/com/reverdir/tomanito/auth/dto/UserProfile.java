package com.reverdir.tomanito.auth.dto;

import com.reverdir.tomanito.user.domain.User;

public record UserProfile(
        String id,
        String name,
        String username
) {
    public static UserProfile from(User user) {
        return new UserProfile(
                String.valueOf(user.getId()),
                user.getName(),
                user.getUsername()
        );
    }
}
