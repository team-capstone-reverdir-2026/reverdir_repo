package com.reverdir.tomanito.mission.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.mission.domain.Mission;
import com.reverdir.tomanito.mission.domain.MissionTemplate;
import com.reverdir.tomanito.mission.dto.CreateMissionRequest;
import com.reverdir.tomanito.mission.dto.MissionListResponse;
import com.reverdir.tomanito.mission.dto.MissionResponse;
import com.reverdir.tomanito.mission.dto.RandomMissionResponse;
import com.reverdir.tomanito.mission.dto.UpdateMissionRequest;
import com.reverdir.tomanito.mission.repository.MissionRepository;
import com.reverdir.tomanito.mission.repository.MissionTemplateRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MissionService {

    private final MissionRepository missionRepository;
    private final MissionTemplateRepository missionTemplateRepository;
    private final ParticipantRepository participantRepository;
    private final RoomRepository roomRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional(readOnly = true)
    public MissionListResponse getMyMissions(Long userId, Long roomId) {
        Participant participant = getParticipant(userId, roomId);
        Room room = participant.getRoom();

        List<MissionResponse> missions = missionRepository
                .findAllByParticipantIdAndRoomIdOrderByCreatedAtAsc(participant.getId(), roomId)
                .stream()
                .map(MissionResponse::from)
                .toList();

        return new MissionListResponse(missions, room.getMissionCount());
    }

    @Transactional(readOnly = true)
    public RandomMissionResponse getRandomMission(List<String> excludeIds) {
        List<Long> excludeTemplateIds = parseExcludeIds(excludeIds);

        List<MissionTemplate> candidates = excludeTemplateIds.isEmpty()
                ? missionTemplateRepository.findAll()
                : missionTemplateRepository.findAllByIdNotIn(excludeTemplateIds);

        if (candidates.isEmpty()) {
            candidates = missionTemplateRepository.findAll();
        }

        if (candidates.isEmpty()) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }

        MissionTemplate selected = candidates.get(secureRandom.nextInt(candidates.size()));
        return new RandomMissionResponse(selected.getContent());
    }

    @Transactional
    public MissionResponse createMission(Long userId, Long roomId, CreateMissionRequest request) {
        Participant participant = getParticipant(userId, roomId);
        Room room = participant.getRoom();

        long currentCount = missionRepository.countByParticipantId(participant.getId());
        if (currentCount >= room.getMissionCount()) {
            throw new CustomException(ErrorCode.MISSION_LIMIT_EXCEEDED);
        }

        Mission mission = Mission.builder()
                .room(room)
                .participant(participant)
                .content(request.content())
                .build();

        return MissionResponse.from(missionRepository.save(mission));
    }

    @Transactional
    public MissionResponse updateMission(Long userId, Long roomId, Long missionId, UpdateMissionRequest request) {
        Mission mission = getOwnedMission(userId, roomId, missionId);
        mission.update(request.content(), request.isCompleted());
        return MissionResponse.from(mission);
    }

    @Transactional
    public void deleteMission(Long userId, Long roomId, Long missionId) {
        Mission mission = getOwnedMission(userId, roomId, missionId);
        missionRepository.delete(mission);
    }

    private Participant getParticipant(Long userId, Long roomId) {
        roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        return participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));
    }

    private Mission getOwnedMission(Long userId, Long roomId, Long missionId) {
        Participant participant = getParticipant(userId, roomId);

        Mission mission = missionRepository.findByIdAndRoomIdWithParticipant(missionId, roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (!mission.getParticipant().getId().equals(participant.getId())) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return mission;
    }

    private List<Long> parseExcludeIds(List<String> excludeIds) {
        if (excludeIds == null || excludeIds.isEmpty()) {
            return Collections.emptyList();
        }

        return excludeIds.stream()
                .map(this::parseExcludeId)
                .filter(id -> id != null)
                .toList();
    }

    private Long parseExcludeId(String excludeId) {
        try {
            return Long.parseLong(excludeId);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
