package com.reverdir.tomanito.report.domain;

import com.reverdir.tomanito.global.common.BaseEntity;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.room.domain.Room;
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
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(
        name = "participant_reports",
        uniqueConstraints = @UniqueConstraint(columnNames = {"participant_id", "room_id"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ParticipantReport extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "participant_id", nullable = false)
    private Participant participant;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ReportStatus status;

    @Column(length = 100)
    private String typeName;

    @Column(length = 500)
    private String typeImageUrl;

    @Column(columnDefinition = "TEXT")
    private String storyText;

    @Builder
    public ParticipantReport(Room room, Participant participant) {
        this.room = room;
        this.participant = participant;
        this.status = ReportStatus.PENDING;
    }

    public void complete(String typeName, String typeImageUrl, String storyText) {
        this.status = ReportStatus.READY;
        this.typeName = typeName;
        this.typeImageUrl = typeImageUrl;
        this.storyText = storyText;
    }
}
