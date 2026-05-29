package com.reverdir.tomanito.note.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.note.domain.Note;
import com.reverdir.tomanito.note.dto.NoteDirection;
import com.reverdir.tomanito.note.dto.NoteListResponse;
import com.reverdir.tomanito.note.dto.NoteResponse;
import com.reverdir.tomanito.note.dto.SendNoteRequest;
import com.reverdir.tomanito.note.repository.NoteRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoteService {

    private final NoteRepository noteRepository;
    private final ParticipantRepository participantRepository;
    private final RoomRepository roomRepository;

    @Transactional
    public NoteResponse sendNote(Long userId, Long roomId, SendNoteRequest request) {
        Participant sender = getParticipantWithManitti(userId, roomId);
        Room room = sender.getRoom();

        validateGameInProgress(room);

        Participant receiver = sender.getManitti();
        if (receiver == null) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        Note note = Note.builder()
                .room(room)
                .sender(sender)
                .receiver(receiver)
                .content(request.content())
                .build();

        Note saved = noteRepository.save(note);
        return NoteResponse.from(saved, NoteDirection.SENT);
    }

    @Transactional
    public NoteResponse markAsRead(Long userId, Long roomId, Long noteId) {
        Participant participant = getParticipant(userId, roomId);

        Note note = noteRepository.findByIdAndRoomId(noteId, roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (!note.getReceiver().getId().equals(participant.getId())) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        note.markAsRead();
        return NoteResponse.from(note, NoteDirection.RECEIVED);
    }

    @Transactional(readOnly = true)
    public NoteListResponse getSentNotes(Long userId, Long roomId, LocalDate from, LocalDate to) {
        Participant participant = getParticipant(userId, roomId);
        Room room = participant.getRoom();

        LocalDateTime fromStart = from != null
                ? from.atStartOfDay()
                : room.getStartedAt().toLocalDateTime();
        LocalDateTime toEnd = to != null
                ? to.atStartOfDay()
                : LocalDateTime.now();


        List<NoteResponse> notes = noteRepository
                .findSentNotes(roomId, participant.getId(), fromStart, toEnd)
                .stream()
                .map(note -> NoteResponse.from(note, NoteDirection.SENT))
                .toList();

        return new NoteListResponse(notes);
    }

    @Transactional(readOnly = true)
    public NoteListResponse getReceivedNotes(Long userId, Long roomId, LocalDate from, LocalDate to) {
        Participant participant = getParticipant(userId, roomId);
        Room room = participant.getRoom();

        LocalDateTime fromStart = from != null
                ? from.atStartOfDay()
                : room.getStartedAt().toLocalDateTime();
        LocalDateTime toEnd = to != null
                ? to.atStartOfDay()
                : LocalDateTime.now();

        List<NoteResponse> notes = noteRepository
                .findReceivedNotes(roomId, participant.getId(), fromStart, toEnd)
                .stream()
                .map(note -> NoteResponse.from(note, NoteDirection.RECEIVED))
                .toList();

        return new NoteListResponse(notes);
    }

    private Participant getParticipant(Long userId, Long roomId) {
        roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        return participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));
    }

    private Participant getParticipantWithManitti(Long userId, Long roomId) {
        roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        return participantRepository.findByRoomIdAndUserIdWithManitti(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));
    }

    private void validateGameInProgress(Room room) {
        if (room.getStatus() == RoomStatus.ENDED) {
            throw new CustomException(ErrorCode.GAME_ENDED);
        }
        if (room.getStatus() != RoomStatus.IN_PROGRESS) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
    }
}
