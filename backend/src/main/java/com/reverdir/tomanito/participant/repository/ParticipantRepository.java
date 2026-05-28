package com.reverdir.tomanito.participant.repository;

import com.reverdir.tomanito.participant.domain.Participant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ParticipantRepository extends JpaRepository<Participant, Long> {

    @Query("SELECT p FROM Participant p JOIN FETCH p.room WHERE p.user.id = :userId")
    List<Participant> findAllByUserIdWithRoom(@Param("userId") Long userId);

    Optional<Participant> findByRoomIdAndUserId(Long roomId, Long userId);

    boolean existsByRoomIdAndUserId(Long roomId, Long userId);

    long countByRoomId(Long roomId);

    @Query("SELECT p FROM Participant p JOIN FETCH p.user WHERE p.room.id = :roomId")
    List<Participant> findAllByRoomIdWithUser(@Param("roomId") Long roomId);

    List<Participant> findAllByRoomId(Long roomId);

    @Query("SELECT p FROM Participant p JOIN FETCH p.manitti WHERE p.room.id = :roomId AND p.user.id = :userId")
    Optional<Participant> findByRoomIdAndUserIdWithManitti(
            @Param("roomId") Long roomId,
            @Param("userId") Long userId
    );

    Optional<Participant> findByRoomIdAndManittiId(Long roomId, Long manittiId);

    @Query("""
            SELECT p FROM Participant p
            JOIN FETCH p.user
            WHERE p.room.id = :roomId AND p.manitti.id = :manittiId
            """)
    Optional<Participant> findManittoByRoomIdAndManittiId(
            @Param("roomId") Long roomId,
            @Param("manittiId") Long manittiId
    );

    @Query("""
            SELECT p FROM Participant p
            JOIN FETCH p.user
            LEFT JOIN FETCH p.manitti m
            LEFT JOIN FETCH m.user
            WHERE p.room.id = :roomId
            """)
    List<Participant> findAllByRoomIdWithUserAndManitti(@Param("roomId") Long roomId);
}
