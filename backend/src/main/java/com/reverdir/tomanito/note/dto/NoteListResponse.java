package com.reverdir.tomanito.note.dto;

import java.util.List;

public record NoteListResponse(
        List<NoteResponse> notes
) {
}
