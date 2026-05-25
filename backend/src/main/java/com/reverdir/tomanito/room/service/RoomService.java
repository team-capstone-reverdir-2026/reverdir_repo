package com.reverdir.tomanito.room.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.dto.CreateRoomRequest;
import com.reverdir.tomanito.room.dto.CreateRoomResponse;
import com.reverdir.tomanito.room.dto.RoomDetail;
import com.reverdir.tomanito.room.dto.RoomJoinPreview;
import com.reverdir.tomanito.room.dto.RoomJoinRequest;
import com.reverdir.tomanito.room.dto.RoomListResponse;
import com.reverdir.tomanito.room.dto.RoomSummary;
import com.reverdir.tomanito.room.repository.RoomRepository;
import com.reverdir.tomanito.user.domain.User;
import com.reverdir.tomanito.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RoomService {

    private static final int INVITE_CODE_LENGTH = 6;
    private static final int MAX_INVITE_CODE_GENERATION_ATTEMPTS = 100;

    private final RoomRepository roomRepository;
    private final ParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public CreateRoomResponse createRoom(Long userId, CreateRoomRequest request) {
        User host = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.UNAUTHORIZED));

        Room room = Room.builder()
                .name(request.name())
                .description(request.description())
                .status(RoomStatus.WAITING)
                .inviteCode(generateUniqueInviteCode())
                .endsAt(request.endsAt())
                .missionCount(request.missionCount())
                .host(host)
                .build();

        Room saved = roomRepository.save(room);
        return CreateRoomResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public RoomListResponse getMyRooms(Long userId) {
        List<RoomSummary> rooms = participantRepository.findAllByUserIdWithRoom(userId).stream()
                .map(participant -> {
                    Room room = participant.getRoom();
                    long participantCount = participantRepository.countByRoomId(room.getId());
                    return RoomSummary.from(room, participantCount);
                })
                .toList();

        return new RoomListResponse(rooms);
    }

    @Transactional(readOnly = true)
    public RoomJoinPreview verifyInviteCode(Long userId, RoomJoinRequest request) {
        Room room = roomRepository.findByInviteCode(request.inviteCode())
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INVITE_CODE));

        if (participantRepository.existsByRoomIdAndUserId(room.getId(), userId)) {
            throw new CustomException(ErrorCode.ALREADY_JOINED);
        }

        long participantCount = participantRepository.countByRoomId(room.getId());
        return RoomJoinPreview.from(room, participantCount);
    }

    @Transactional(readOnly = true)
    public RoomDetail getRoomDetail(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));

        long participantCount = participantRepository.countByRoomId(roomId);
        boolean isHost = room.getHost().getId().equals(userId);
        int daysRemaining = calculateDaysRemaining(room.getEndsAt());

        return RoomDetail.from(room, participantCount, daysRemaining, isHost);
    }

    private int calculateDaysRemaining(OffsetDateTime endsAt) {
        long days = ChronoUnit.DAYS.between(OffsetDateTime.now(), endsAt);
        return (int) Math.max(0, days);
    }

    private String generateUniqueInviteCode() {
        for (int attempt = 0; attempt < MAX_INVITE_CODE_GENERATION_ATTEMPTS; attempt++) {
            String inviteCode = generateInviteCode();
            if (!roomRepository.existsByInviteCode(inviteCode)) {
                return inviteCode;
            }
        }
        throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }

    private String generateInviteCode() {
        int code = secureRandom.nextInt((int) Math.pow(10, INVITE_CODE_LENGTH));
        return String.format("%0" + INVITE_CODE_LENGTH + "d", code);
    }
}
