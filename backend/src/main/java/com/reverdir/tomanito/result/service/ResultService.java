package com.reverdir.tomanito.result.service;

import com.reverdir.tomanito.global.config.GeminiClient;
import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.result.dto.ManittoChainItem;
import com.reverdir.tomanito.result.dto.ManittoRevealResult;
import com.reverdir.tomanito.result.dto.MyReportResponse;
import com.reverdir.tomanito.result.dto.ParticipantSummary;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ResultService {

    private final RoomRepository roomRepository;
    private final ParticipantRepository participantRepository;

    @Transactional(readOnly = true)
    public ManittoRevealResult getManittoReveal(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (room.getStatus() != RoomStatus.ENDED) {
            throw new CustomException(ErrorCode.GAME_NOT_ENDED);
        }

        Participant me = participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));

        Participant myManitto = participantRepository
                .findManittoByRoomIdAndManittiId(roomId, me.getId())
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        List<ManittoChainItem> chain = participantRepository.findAllByRoomIdWithUserAndManitti(roomId).stream()
                .filter(participant -> participant.getManitti() != null)
                .map(participant -> new ManittoChainItem(
                        ParticipantSummary.from(participant),
                        ParticipantSummary.from(participant.getManitti())
                ))
                .toList();

        return new ManittoRevealResult(
                ParticipantSummary.from(myManitto),
                chain
        );
    }

    @Transactional(readOnly = true)
    public MyReportResponse getMyReport(Long userId, Long aLong) {

    }
}
