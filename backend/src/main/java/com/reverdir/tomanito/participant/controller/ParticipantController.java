package com.reverdir.tomanito.participant.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.participant.dto.JoinRoomRequest;
import com.reverdir.tomanito.participant.dto.ParticipantListResponse;
import com.reverdir.tomanito.participant.dto.ParticipantResponse;
import com.reverdir.tomanito.participant.service.ParticipantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/rooms/{roomId}/participants")
@RequiredArgsConstructor
public class ParticipantController {

    private final ParticipantService participantService;

    @GetMapping
    public ParticipantListResponse getParticipants(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return participantService.getParticipants(userId, parseRoomId(roomId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ParticipantResponse joinRoom(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @Valid @RequestBody JoinRoomRequest request
    ) {
        return participantService.joinRoom(userId, parseRoomId(roomId), request);
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
