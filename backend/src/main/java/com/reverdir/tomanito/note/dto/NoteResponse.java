package com.reverdir.tomanito.note.dto;

import com.reverdir.tomanito.note.domain.Note;

import java.time.LocalDateTime;

public record NoteResponse(
        String id,
        String content,
        boolean isRead,
        LocalDateTime sentAt,
        NoteDirection direction
) {
    public static NoteResponse from(Note note, NoteDirection direction) {
        return new NoteResponse(
                String.valueOf(note.getId()),
                note.getContent(),
                note.isRead(),
                note.getCreatedAt(),
                direction
        );
    }
}
