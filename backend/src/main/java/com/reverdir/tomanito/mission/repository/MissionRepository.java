package com.reverdir.tomanito.mission.repository;

import com.reverdir.tomanito.mission.domain.Mission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface MissionRepository extends JpaRepository<Mission, Long> {

    long countByParticipantId(Long participantId);

    List<Mission> findAllByParticipantIdAndRoomIdOrderByCreatedAtAsc(Long participantId, Long roomId);

    @Query("SELECT m FROM Mission m JOIN FETCH m.participant WHERE m.id = :missionId AND m.room.id = :roomId")
    Optional<Mission> findByIdAndRoomIdWithParticipant(
            @Param("missionId") Long missionId,
            @Param("roomId") Long roomId
    );
}