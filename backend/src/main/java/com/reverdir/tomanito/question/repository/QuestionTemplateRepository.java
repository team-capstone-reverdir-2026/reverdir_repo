package com.reverdir.tomanito.question.repository;

import com.reverdir.tomanito.question.domain.QuestionTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface QuestionTemplateRepository extends JpaRepository<QuestionTemplate, Long> {

    List<QuestionTemplate> findAllByIdNotIn(Collection<Long> ids);
}
