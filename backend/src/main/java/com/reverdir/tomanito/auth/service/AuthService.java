package com.reverdir.tomanito.auth.service;

import com.reverdir.tomanito.auth.dto.AuthResponse;
import com.reverdir.tomanito.auth.dto.LoginRequest;
import com.reverdir.tomanito.auth.dto.RefreshTokenRequest;
import com.reverdir.tomanito.auth.dto.RegisterRequest;
import com.reverdir.tomanito.auth.jwt.JwtProvider;
import com.reverdir.tomanito.auth.util.PasswordHasher;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.user.domain.User;
import com.reverdir.tomanito.user.repository.UserRepository;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new CustomException(ErrorCode.DUPLICATE_USERNAME);
        }

        User user = User.builder()
                .name(request.name())
                .username(request.username())
                .password(PasswordHasher.encode(request.password()))
                .build();

        User saved = userRepository.save(user);
        return createAuthResponse(saved);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_CREDENTIALS));

        if (!PasswordHasher.matches(request.password(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_CREDENTIALS);
        }

        return createAuthResponse(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse refresh(RefreshTokenRequest request) {
        Claims claims = jwtProvider.validateRefreshToken(request.refreshToken());
        Long userId = jwtProvider.getUserId(claims);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.UNAUTHORIZED));

        return createAuthResponse(user);
    }

    private AuthResponse createAuthResponse(User user) {
        String accessToken = jwtProvider.createAccessToken(user);
        String refreshToken = jwtProvider.createRefreshToken(user);
        return AuthResponse.of(accessToken, refreshToken, user);
    }
}
