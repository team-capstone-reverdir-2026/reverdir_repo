package com.reverdir.tomanito.room.repository;

import com.reverdir.tomanito.room.domain.Room;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long> {

    boolean existsByInviteCode(String inviteCode);

    Optional<Room> findByInviteCode(String inviteCode);
}
