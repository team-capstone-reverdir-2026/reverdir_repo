package com.reverdir.tomanito.mission.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.mission.dto.CreateMissionRequest;
import com.reverdir.tomanito.mission.dto.MissionListResponse;
import com.reverdir.tomanito.mission.dto.MissionResponse;
import com.reverdir.tomanito.mission.dto.RandomMissionResponse;
import com.reverdir.tomanito.mission.dto.UpdateMissionRequest;
import com.reverdir.tomanito.mission.service.MissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/v1/rooms/{roomId}/missions")
@RequiredArgsConstructor
public class MissionController {

    private final MissionService missionService;

    @GetMapping
    public MissionListResponse getMyMissions(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return missionService.getMyMissions(userId, parseRoomId(roomId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MissionResponse createMission(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @Valid @RequestBody CreateMissionRequest request
    ) {
        return missionService.createMission(userId, parseRoomId(roomId), request);
    }

    @PatchMapping("/{missionId}")
    public MissionResponse updateMission(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @PathVariable String missionId,
            @Valid @RequestBody UpdateMissionRequest request
    ) {
        return missionService.updateMission(userId, parseRoomId(roomId), parseMissionId(missionId), request);
    }

    @DeleteMapping("/{missionId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteMission(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @PathVariable String missionId
    ) {
        missionService.deleteMission(userId, parseRoomId(roomId), parseMissionId(missionId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }

    private Long parseMissionId(String missionId) {
        try {
            return Long.parseLong(missionId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
