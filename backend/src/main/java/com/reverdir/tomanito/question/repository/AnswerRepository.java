package com.reverdir.tomanito.question.repository;

import com.reverdir.tomanito.question.domain.Answer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer, Long> {

    Optional<Answer> findByParticipantIdAndQuestionId(Long participantId, Long questionId);

    List<Answer> findAllByParticipantIdAndQuestionIdIn(Long participantId, Collection<Long> questionIds);
}
