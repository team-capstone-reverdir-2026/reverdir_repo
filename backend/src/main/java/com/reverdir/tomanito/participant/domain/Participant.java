package com.reverdir.tomanito.participant.domain;

import com.reverdir.tomanito.global.common.BaseEntity;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.user.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(
        name = "participants",
        uniqueConstraints = @UniqueConstraint(columnNames = {"room_id", "user_id"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Participant extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 20)
    private String displayName;

    @Column(nullable = false)
    private boolean isHost;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manitti_id")
    private Participant manitti;

    @Builder
    public Participant(Room room, User user, String displayName, boolean isHost) {
        this.room = room;
        this.user = user;
        this.displayName = displayName;
        this.isHost = isHost;
    }

    public void assignManitti(Participant manitti) {
        this.manitti = manitti;
    }
}
