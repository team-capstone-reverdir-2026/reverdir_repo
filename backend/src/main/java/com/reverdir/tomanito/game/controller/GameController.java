package com.reverdir.tomanito.game.controller;

import com.reverdir.tomanito.game.dto.GameEndResponse;
import com.reverdir.tomanito.game.dto.GameStartResponse;
import com.reverdir.tomanito.game.dto.MyManittiResponse;
import com.reverdir.tomanito.game.service.GameService;
import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/rooms/{roomId}")
@RequiredArgsConstructor
public class GameController {

    private final GameService gameService;

    @PostMapping("/game/start")
    public GameStartResponse startGame(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return gameService.startGame(userId, parseRoomId(roomId));
    }

    @PostMapping("/game/end")
    public GameEndResponse endGame(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return gameService.endGame(userId, parseRoomId(roomId));
    }

    @GetMapping("/my-manitti")
    public MyManittiResponse getMyManitti(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return gameService.getMyManitti(userId, parseRoomId(roomId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
