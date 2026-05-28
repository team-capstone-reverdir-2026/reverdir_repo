package com.reverdir.tomanito.note.domain;

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
@Table(name = "notes")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Note extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", nullable = false)
    private Participant sender;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id", nullable = false)
    private Participant receiver;

    @Column(nullable = false, length = 1000)
    private String content;

    @Column(nullable = false)
    private boolean isRead;

    @Builder
    public Note(Room room, Participant sender, Participant receiver, String content) {
        this.room = room;
        this.sender = sender;
        this.receiver = receiver;
        this.content = content;
        this.isRead = false;
    }

    public void markAsRead() {
        this.isRead = true;
    }
}
