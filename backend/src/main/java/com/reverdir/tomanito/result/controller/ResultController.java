package com.reverdir.tomanito.result.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.result.dto.ManittoRevealResult;
import com.reverdir.tomanito.result.dto.MyReportResponse;
import com.reverdir.tomanito.result.service.ResultService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/rooms/{roomId}/results")
@RequiredArgsConstructor
public class ResultController {

    private final ResultService resultService;

    @GetMapping("/manitto-reveal")
    public ManittoRevealResult getManittoReveal(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return resultService.getManittoReveal(userId, parseRoomId(roomId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }

    @GetMapping("/my-report")
    public MyReportResponse getMyReport(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return resultService.getMyReport(userId, parseRoomId(roomId));
    }
}
