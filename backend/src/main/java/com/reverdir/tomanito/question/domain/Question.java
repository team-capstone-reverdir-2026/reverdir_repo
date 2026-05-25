package com.reverdir.tomanito.question.domain;

import com.reverdir.tomanito.global.common.BaseEntity;
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
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(
        name = "questions",
        uniqueConstraints = @UniqueConstraint(columnNames = {"room_id", "question_date"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Question extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "question_date", nullable = false)
    private LocalDate questionDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_template_id")
    private QuestionTemplate questionTemplate;

    @Builder
    public Question(Room room, String content, LocalDate questionDate, QuestionTemplate questionTemplate) {
        this.room = room;
        this.content = content;
        this.questionDate = questionDate;
        this.questionTemplate = questionTemplate;
    }
}
