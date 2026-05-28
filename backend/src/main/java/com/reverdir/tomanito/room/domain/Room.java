package com.reverdir.tomanito.room.domain;

import com.reverdir.tomanito.global.common.BaseEntity;
import com.reverdir.tomanito.user.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Entity
@Table(name = "rooms")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Room extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RoomStatus status;

    @Column(nullable = false, unique = true, length = 6)
    private String inviteCode;

    @Column(nullable = false)
    private OffsetDateTime endsAt;

    @Column(nullable = false)
    private int missionCount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "host_id", nullable = false)
    private User host;

    private OffsetDateTime startedAt;

    private OffsetDateTime endedAt;

    @Builder
    public Room(
            String name,
            String description,
            RoomStatus status,
            String inviteCode,
            OffsetDateTime endsAt,
            int missionCount,
            User host
    ) {
        this.name = name;
        this.description = description;
        this.status = status;
        this.inviteCode = inviteCode;
        this.endsAt = endsAt;
        this.missionCount = missionCount;
        this.host = host;
    }

    public void start(OffsetDateTime startedAt) {
        this.status = RoomStatus.IN_PROGRESS;
        this.startedAt = startedAt;
    }

    public void end(OffsetDateTime endedAt) {
        this.status = RoomStatus.ENDED;
        this.endedAt = endedAt;
    }
}
