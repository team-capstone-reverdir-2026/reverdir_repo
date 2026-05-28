package com.reverdir.tomanito.participant.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.mission.repository.MissionRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.dto.JoinRoomRequest;
import com.reverdir.tomanito.participant.dto.ParticipantListResponse;
import com.reverdir.tomanito.participant.dto.ParticipantResponse;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import com.reverdir.tomanito.user.domain.User;
import com.reverdir.tomanito.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ParticipantService {

    private final ParticipantRepository participantRepository;
    private final RoomRepository roomRepository;
    private final UserRepository userRepository;
    private final MissionRepository missionRepository;

    @Transactional(readOnly = true)
    public ParticipantListResponse getParticipants(Long userId, Long roomId) {
        validateRoomAccess(userId, roomId);

        List<ParticipantResponse> participants = participantRepository.findAllByRoomIdWithUser(roomId).stream()
                .map(participant -> ParticipantResponse.from(
                        participant,
                        missionRepository.countByParticipantId(participant.getId())
                ))
                .toList();

        return new ParticipantListResponse(participants);
    }

    @Transactional
    public ParticipantResponse joinRoom(Long userId, Long roomId, JoinRoomRequest request) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (room.getStatus() != RoomStatus.WAITING) {
            throw new CustomException(ErrorCode.GAME_ALREADY_STARTED);
        }

        if (participantRepository.existsByRoomIdAndUserId(roomId, userId)) {
            throw new CustomException(ErrorCode.ALREADY_JOINED);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.UNAUTHORIZED));

        boolean isHost = room.getHost().getId().equals(userId);

        Participant participant = Participant.builder()
                .room(room)
                .user(user)
                .displayName(request.displayName())
                .isHost(isHost)
                .build();

        Participant saved = participantRepository.save(participant);
        return ParticipantResponse.from(saved, 0);
    }

    private void validateRoomAccess(Long userId, Long roomId) {
        roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));
    }
}
