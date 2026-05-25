package com.reverdir.tomanito.mission.repository;

import com.reverdir.tomanito.mission.domain.MissionTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface MissionTemplateRepository extends JpaRepository<MissionTemplate, Long> {

    List<MissionTemplate> findAllByIdNotIn(Collection<Long> ids);
}
