package com.reverdir.tomanito.mission.domain;

import com.reverdir.tomanito.global.common.BaseEntity;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.room.domain.Room;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

@Entity
@Table(name = "missions")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Mission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "participant_id", nullable = false)
    private Participant participant;

    @Column(nullable = false, length = 200)
    private String content;

    @Column(nullable = false)
    private boolean isCompleted;

    @Builder
    public Mission(Room room, Participant participant, String content) {
        this.room = room;
        this.participant = participant;
        this.content = content;
        this.isCompleted = false;
    }

    public void update(String content, Boolean isCompleted) {
        if (content != null) {
            this.content = content;
        }
        if (isCompleted != null) {
            this.isCompleted = isCompleted;
        }
    }
}
