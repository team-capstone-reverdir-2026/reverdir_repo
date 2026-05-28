package com.reverdir.tomanito.note.controller;

import com.reverdir.tomanito.global.auth.LoginUser;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.note.dto.NoteListResponse;
import com.reverdir.tomanito.note.dto.NoteResponse;
import com.reverdir.tomanito.note.dto.SendNoteRequest;
import com.reverdir.tomanito.note.service.NoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/v1/rooms/{roomId}/notes")
@RequiredArgsConstructor
public class NoteController {

    private final NoteService noteService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public NoteResponse sendNote(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @Valid @RequestBody SendNoteRequest request
    ) {
        return noteService.sendNote(userId, parseRoomId(roomId), request);
    }

    @GetMapping("/sent")
    public NoteListResponse getSentNotes(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        return noteService.getSentNotes(userId, parseRoomId(roomId), from, to);
    }

    @GetMapping("/received")
    public NoteListResponse getReceivedNotes(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        return noteService.getReceivedNotes(userId, parseRoomId(roomId), from, to);
    }

    @PatchMapping("/{noteId}/read")
    public NoteResponse markAsRead(
            @LoginUser Long userId,
            @PathVariable String roomId,
            @PathVariable String noteId
    ) {
        return noteService.markAsRead(userId, parseRoomId(roomId), parseNoteId(noteId));
    }

    private Long parseRoomId(String roomId) {
        try {
            return Long.parseLong(roomId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }

    private Long parseNoteId(String noteId) {
        try {
            return Long.parseLong(noteId);
        } catch (NumberFormatException e) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }
    }
}
