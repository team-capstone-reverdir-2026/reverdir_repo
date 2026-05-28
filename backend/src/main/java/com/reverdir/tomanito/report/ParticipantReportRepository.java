package com.reverdir.tomanito.report;

import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.report.domain.ParticipantReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ParticipantReportRepository extends JpaRepository<ParticipantReport, Long> {

    Optional<ParticipantReport> findByParticipant(Participant participant);
}
