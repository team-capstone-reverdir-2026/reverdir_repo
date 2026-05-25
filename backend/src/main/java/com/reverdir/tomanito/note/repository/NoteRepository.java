package com.reverdir.tomanito.note.repository;

import com.reverdir.tomanito.note.domain.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface NoteRepository extends JpaRepository<Note, Long> {

    Optional<Note> findByIdAndRoomId(Long id, Long roomId);

    @Query("""
            SELECT n FROM Note n
            WHERE n.room.id = :roomId AND n.sender.id = :participantId
            AND (:fromStart IS NULL OR n.createdAt >= :fromStart)
            AND (:toEnd IS NULL OR n.createdAt <= :toEnd)
            ORDER BY n.createdAt DESC
            """)
    List<Note> findSentNotes(
            @Param("roomId") Long roomId,
            @Param("participantId") Long participantId,
            @Param("fromStart") LocalDateTime fromStart,
            @Param("toEnd") LocalDateTime toEnd
    );

    @Query("""
            SELECT n FROM Note n
            WHERE n.room.id = :roomId AND n.receiver.id = :participantId
            AND (:fromStart IS NULL OR n.createdAt >= :fromStart)
            AND (:toEnd IS NULL OR n.createdAt <= :toEnd)
            ORDER BY n.createdAt DESC
            """)
    List<Note> findReceivedNotes(
            @Param("roomId") Long roomId,
            @Param("participantId") Long participantId,
            @Param("fromStart") LocalDateTime fromStart,
            @Param("toEnd") LocalDateTime toEnd
    );
}
