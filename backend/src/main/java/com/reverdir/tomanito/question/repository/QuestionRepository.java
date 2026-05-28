package com.reverdir.tomanito.question.repository;

import com.reverdir.tomanito.question.domain.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface QuestionRepository extends JpaRepository<Question, Long> {

    Optional<Question> findByRoomIdAndQuestionDate(Long roomId, LocalDate questionDate);

    List<Question> findAllByRoomIdAndQuestionDateLessThanEqualOrderByQuestionDateDesc(
            Long roomId,
            LocalDate questionDate
    );

    @Query("SELECT DISTINCT q.questionTemplate.id FROM Question q WHERE q.room.id = :roomId AND q.questionTemplate IS NOT NULL")
    List<Long> findUsedTemplateIdsByRoomId(@Param("roomId") Long roomId);
}
