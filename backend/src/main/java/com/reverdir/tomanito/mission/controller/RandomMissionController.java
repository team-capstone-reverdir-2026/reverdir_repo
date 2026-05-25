package com.reverdir.tomanito.mission.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.mission.dto.RandomMissionResponse;
import com.reverdir.tomanito.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/v1/missions")
@RequiredArgsConstructor
public class RandomMissionController {

    private final MissionService missionService;

    @GetMapping("/random")
    public RandomMissionResponse getRandomMission(
            @LoginUser Long userId,
            @RequestParam(required = false) List<String> excludeIds
    ) {
        return missionService.getRandomMission(excludeIds);
    }
}
