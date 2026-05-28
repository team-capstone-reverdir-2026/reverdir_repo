package com.reverdir.tomanito.question.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.question.dto.AnswerResponse;
import com.reverdir.tomanito.question.dto.QuestionHistoryResponse;
import com.reverdir.tomanito.question.dto.SubmitAnswerRequest;
import com.reverdir.tomanito.question.dto.TodayQuestionResponse;
import com.reverdir.tomanito.question.service.QuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/rooms/{roomId}/questions")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    @GetMapping("/today")
    public TodayQuestionResponse getTodayQuestion(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return questionService.getTodayQuestion(userId, parseRoomId(roomId));
    }

    @PostMapping("/today/answer")
    public AnswerResponse submitAnswer(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @Valid @RequestBody SubmitAnswerRequest request
    ) {
        return questionService.submitAnswer(userId, parseRoomId(roomId), request);
    }

    @GetMapping("/history")
    public QuestionHistoryResponse getQuestionHistory(
            @LoginUser Long userId,
            @PathVariable String roomId
    ) {
        return questionService.getQuestionHistory(userId, parseRoomId(roomId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
