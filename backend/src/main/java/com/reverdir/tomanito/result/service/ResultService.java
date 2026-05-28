package com.reverdir.tomanito.result.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.note.domain.Note;
import com.reverdir.tomanito.note.repository.NoteRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.report.ParticipantReportRepository;
import com.reverdir.tomanito.report.domain.ParticipantReport;
import com.reverdir.tomanito.report.domain.ReportStatus;
import com.reverdir.tomanito.result.CharacterType;
import com.reverdir.tomanito.result.dto.ManittoChainItem;
import com.reverdir.tomanito.result.dto.ManittoRevealResult;
import com.reverdir.tomanito.result.dto.MyReportResponse;
import com.reverdir.tomanito.result.dto.ParticipantSummary;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ResultService {

    private final RoomRepository roomRepository;
    private final ParticipantRepository participantRepository;
    private final NoteRepository noteRepository;
    private final ParticipantReportRepository participantReportRepository;
    private final RestClient restClient = RestClient.builder().build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${google.gemini.api.key}")
    private String apiKey;

    @Value("${google.gemini.model}")
    private String modelName;

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

    @Transactional
    public MyReportResponse getMyReport(Long userId, Long roomId) {
        Participant participant = participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        Optional<ParticipantReport> existingReport = participantReportRepository
                .findByParticipant(participant);

        Room room = roomRepository.findById(roomId).orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (existingReport.isPresent()) {
            ParticipantReport report = existingReport.get();
            return MyReportResponse.builder()
                    .status("READY")
                    .typeName(report.getTypeName())
                    .typeImageUrl(report.getTypeImageUrl())
                    .storyText(report.getStoryText())
                    .build();
        }

        List<Note> sentNotes = noteRepository.findAllBySender(participant);

        int totalRoomQuestions = 5;
        int myAnswerCount = 5;
        int hintParticipationRate = (myAnswerCount * 100) / totalRoomQuestions;

        Map<String, Object> statsMap = analyzeMetadata(sentNotes, hintParticipationRate);

        CharacterType determinedType = determineCharacterType(statsMap);

        String prompt = String.format(
                "너는 마니또 서비스 성향 분석가야. 특정 유저의 이번 마니또 활동 데이터 내역은 다음과 같아.\n\n" +
                        "[유저 활동 통계 내역]\n" +
                        "- 판별된 캐릭터 유형: %s\n" +
                        "- 총 작성한 쪽지 개수: %d개\n" +
                        "- 쪽지 한 개당 평균 글자 수: %d자\n" +
                        "- 시간대별 발송 빈도: [낮(06-18시)] %d회, [밤/새벽(00-06시)] %d회, [저녁(18-00시)] %d회\n" +
                        "- 오늘의 질문(힌트) 미션 참여도: %d%%\n\n" +
                        "이 수치적 증거들을 참고하되 절대 구체적 수치나 행동 방식을 직접적으로 드러내지 말고, 추상적인 비유나 일반화를 사용해 " +
                        "각 유형 스타일의 말투로 개인 유저 맞춤형 설명글 3줄을 작성해줘. 다른 수식어나 마크다운 없이 평문 텍스트만 반환해. 각 유형별 말투는 밑의 예시를 참고하되 오로지 '말투'만 참고하고 내용은 개인에 맞추어 재구성해줘.\n" +
                        "예시(로보트): 삐빅- 분석 결과 보고." +
                        "분석 결과- 마니또에게 호감 수치 nn퍼센트를 보유 중입니다. 삐리릭- 최근 행동 패턴 확인- ~ 최종 결론: 당신은 '좋아하면서 숨기는 인간형 개체'로 추정됩니다. 삐빅." +
                        "예시(쥐돌이): 찍찍... 너 말이야... 치즈 숨기듯 정체 숨기고 다닌다 찍... 근데 자꾸 밤마다 쪽지 보내고... 매일 힐끔거리고... 마음은 이미 들킨 거 아냐 찍?" +
                        "예시(곰돌이): 크왕. 말은 자주 안 남기는데, 한번 꺼낸 마음은 묵직하게 오래 남는다.\n" +
                        "짧게 스쳐 지나갈 수도 있었을 텐데 굳이 깊은 숲속까지 발자국 남긴 걸 보면, 생각보다 마음이 깊은 타입이다.\n" +
                        "최종 판정이다. 조용해 보여도 한 번 마음 쓰기 시작하면 오래 품고 있는 곰 같은 개체다. 크르릉." +
                        "예시(강아지): 멍멍~ 여기저기 꼬리 흔든 흔적이 엄청 많다멍!\n" +
                        "툭툭 가볍게 다가오는 것 같아도, 밝은 시간마다 꾸준히 온기 남기는 거 보면 사람 좋아하는 강아지 느낌이 난다멍~\n" +
                        "오늘의 판정! 마음 표현을 숨기기보단 자꾸 반가움이 새어나오는 다정한 멍멍이다멍!!!" +
                        "예시(고양이): 냐앙... 딱히 계속 지켜본 건 아닌데, 은근 흔적 많이 남기더라냥.\n" +
                        "낮엔 아무렇지도 않은 척하면서도 조용한 시간만 되면 마음 꼬리 살랑거리는 거, 다 티 난다냥.\n" +
                        "흥... 결론은 하나야. 관심 없는 척 제일 열심히 하는 타입. 완전 뻔하다냥.\n",
                determinedType.getName(),
                (int) statsMap.get("noteCount"),
                (int) statsMap.get("avgLength"),
                (int) statsMap.get("dayCount"),
                (int) statsMap.get("nightCount"),
                (int) statsMap.get("eveningCount"),
                (int) statsMap.get("hintRate")
        );

        // 4. Gemini 2.5 Flash 호출
        String storyText = callGeminiApi(prompt);

        ParticipantReport newReport = ParticipantReport.builder()
                .participant(participant)
                .room(room)
                .status(ReportStatus.READY)
                .typeName(determinedType.getName())
                .typeImageUrl(determinedType.getImageUrl())
                .storyText(storyText)
                .build();

        participantReportRepository.save(newReport);

        return MyReportResponse.builder()
                .status("READY")
                .typeName(newReport.getTypeName())
                .typeImageUrl(newReport.getTypeImageUrl())
                .storyText(newReport.getStoryText())
                .build();
    }

    private Map<String, Object> analyzeMetadata(List<Note> notes, int hintRate) {
        int totalLength = 0;
        int dayCount = 0;      // 낮 (06:00 ~ 18:00)
        int nightCount = 0;    // 밤/새벽 (00:00 ~ 06:00)
        int eveningCount = 0;  // 저녁 (18:00 ~ 24:00)

        for (Note note : notes) {
            totalLength += note.getContent().length();
            LocalTime time = note.getCreatedAt().toLocalTime();
            int hour = time.getHour();

            if (hour >= 6 && hour < 18) {
                dayCount++;
            } else if (hour >= 0 && hour < 6) {
                nightCount++;
            } else {
                eveningCount++;
            }
        }

        int noteCount = notes.size();
        int avgLength = noteCount == 0 ? 0 : totalLength / noteCount;

        return Map.of(
                "noteCount", noteCount,
                "avgLength", avgLength,
                "dayCount", dayCount,
                "nightCount", nightCount,
                "eveningCount", eveningCount,
                "hintRate", hintRate
        );
    }

    private CharacterType determineCharacterType(Map<String, Object> stats) {
        int noteCount = (int) stats.get("noteCount");
        int avgLength = (int) stats.get("avgLength");
        int dayCount = (int) stats.get("dayCount");
        int nightCount = (int) stats.get("nightCount");
        int hintRate = (int) stats.get("hintRate");

        // 1. 🤖 깡통 로보트: 쪽지 1개 이하 + 힌트 참여도 100%
        if (noteCount <= 2 && hintRate == 100) {
            return CharacterType.ROBOT;
        }

        // 2. 🐻 듬직한 곰돌이: 쪽지 2개 이하 + 평균 길이 100자 이상
        if (noteCount > 0 && noteCount <= 2 && avgLength >= 100) {
            return CharacterType.BEAR;
        }

        // 3. 🐱 츤데레 고양이: 밤/새벽 시간대 활동 비율이 70% 이상
        if (noteCount > 0) {
            double nightRatio = (double) nightCount / noteCount;
            if (nightRatio >= 0.70) {
                return CharacterType.CAT;
            }
        }

        // 4. 🐶 다정 댕댕이: 쪽지 5개 이상 + 낮 활동이 가장 많음 (단문 위주)
        if (noteCount >= 5 && dayCount >= (noteCount - dayCount)) {
            return CharacterType.DOG;
        }

        // 5. 🐹 부지런한 쥐돌이: 기본 값 (꾸준하고 평범한 성실함)
        return CharacterType.MOUSE;
    }

    private String callGeminiApi(String prompt) {
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey;

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))),
                "generationConfig", Map.of("temperature", 0.9)
        );

        try {
            String response = restClient.post()
                    .uri(url)
                    .header("Content-Type", "application/json")
                    .body(requestBody)
                    .retrieve()
                    .body(String.class);

            JsonNode root = objectMapper.readTree(response);
            String rawText = root.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();
            return rawText.replace("```json", "").replace("```", "").trim();
        } catch (Exception e) {
            throw new InternalError(e.getMessage());
        }
    }
}
