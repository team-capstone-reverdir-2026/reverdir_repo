package com.reverdir.tomanito.room.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.room.dto.CreateRoomRequest;
import com.reverdir.tomanito.room.dto.CreateRoomResponse;
import com.reverdir.tomanito.room.dto.RoomDetail;
import com.reverdir.tomanito.room.dto.RoomJoinPreview;
import com.reverdir.tomanito.room.dto.RoomJoinRequest;
import com.reverdir.tomanito.room.dto.RoomListResponse;
import com.reverdir.tomanito.room.service.RoomService;
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
@RequestMapping("/v1/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;

    @GetMapping
    public RoomListResponse getMyRooms(@LoginUser Long userId) {
        return roomService.getMyRooms(userId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CreateRoomResponse createRoom(
            @LoginUser Long userId,
            @Valid @RequestBody CreateRoomRequest request
    ) {
        return roomService.createRoom(userId, request);
    }

    @PostMapping("/join")
    public RoomJoinPreview verifyInviteCode(
            @LoginUser Long userId,
            @Valid @RequestBody RoomJoinRequest request
    ) {
        return roomService.verifyInviteCode(userId, request);
    }

    @GetMapping("/{roomId}")
    public RoomDetail getRoomDetail(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return roomService.getRoomDetail(userId, parseRoomId(roomId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
