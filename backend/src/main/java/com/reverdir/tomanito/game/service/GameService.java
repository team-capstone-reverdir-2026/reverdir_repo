package com.reverdir.tomanito.game.service;

import com.reverdir.tomanito.game.dto.GameEndResponse;
import com.reverdir.tomanito.game.dto.GameStartResponse;
import com.reverdir.tomanito.game.dto.MyManittiResponse;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.mission.repository.MissionRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GameService {

    private final RoomRepository roomRepository;
    private final ParticipantRepository participantRepository;
    private final MissionRepository missionRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public GameStartResponse startGame(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (!room.getHost().getId().equals(userId)) {
            throw new CustomException(ErrorCode.NOT_HOST);
        }

        if (room.getStatus() != RoomStatus.WAITING) {
            throw new CustomException(ErrorCode.GAME_ALREADY_STARTED);
        }

        List<Participant> participants = participantRepository.findAllByRoomId(roomId);

        if (participants.size() < 2) {
            throw new CustomException(ErrorCode.NOT_ENOUGH_PARTICIPANTS);
        }

        validateAllMissionsSubmitted(room, participants);
        assignManittiRandomly(participants);

        OffsetDateTime startedAt = OffsetDateTime.now();
        room.start(startedAt);

        return new GameStartResponse(room.getStatus(), startedAt);
    }

    @Transactional
    public GameEndResponse endGame(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (!room.getHost().getId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        if (room.getStatus() != RoomStatus.IN_PROGRESS) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        OffsetDateTime endedAt = OffsetDateTime.now();
        room.end(endedAt);

        return new GameEndResponse(room.getStatus(), endedAt);
    }

    @Transactional(readOnly = true)
    public MyManittiResponse getMyManitti(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (room.getStatus() != RoomStatus.IN_PROGRESS) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        Participant participant = participantRepository.findByRoomIdAndUserIdWithManitti(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));

        if (participant.getManitti() == null) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return new MyManittiResponse(participant.getManitti().getDisplayName());
    }

    private void validateAllMissionsSubmitted(Room room, List<Participant> participants) {
        for (Participant participant : participants) {
            long missionCount = missionRepository.countByParticipantId(participant.getId());
            if (missionCount < room.getMissionCount()) {
                throw new CustomException(ErrorCode.NOT_ENOUGH_MISSION);
            }
        }
    }

    private void assignManittiRandomly(List<Participant> participants) {
        List<Participant> shuffled = new ArrayList<>(participants);
        Collections.shuffle(shuffled, secureRandom);

        int size = shuffled.size();
        for (int i = 0; i < size; i++) {
            Participant manitti = shuffled.get((i + 1) % size);
            shuffled.get(i).assignManitti(manitti);
        }
    }
}
