package com.reverdir.tomanito;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DemoService {
    @Value("${google.gemini.api.key}")
    private String apiKey;

    @Value("${google.gemini.model}")
    private String model;

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    public DemoDto.DemoResponse analyzeNote(String noteContent) {
        String url = String.format(
                "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                model, apiKey
        );

        int length = noteContent.length();
        int hour = LocalDateTime.now().getHour();
        String timeSlot = (hour >= 23 || hour < 6) ? "새벽 (23시~6시)"
                : (hour >= 6  && hour < 12) ? "오전 (6시~12시)"
                : (hour >= 12 && hour < 18) ? "오후 (12시~18시)"
                :                             "저녁 (18시~23시)";
        String lengthLabel = length <= 15  ? "매우 짧음 (15자 이하)"
                : length <= 40  ? "보통 (16~40자)"
                : length <= 80  ? "긺 (41~80자)"
                :                "매우 긺 (81자 이상)";


        String systemPrompt = """
            당신은 마니또 게임 참여자의 쪽지 데이터를 분석해 캐릭터 페르소나를 부여하는 분석가입니다.
            
            분석 절차 (반드시 이 순서로 내부 추론을 수행하십시오)
            
            1. 각 시그널 점수화
            아래 기준에 따라 각 항목을 점수화합니다.
            
            [시간대 → 감성 온도]
            - 새벽 (23시~6시)  : 감성적 +2 / 이성적 -1
            - 오전 (6시~12시)  : 이성적 +1 / 감성적 -1
            - 오후 (12시~18시) : 중립 0
            - 저녁 (18시~23시) : 감성적 +1
            
            [글자 수 → 표현 방식]
            - 15자 이하  : 과묵함 +2 / 장난꾸러기 가능성 +1
            - 16~40자    : 중립, 내용에 집중
            - 41~80자    : 다정함 +1 / 상냥함 +1
            - 81자 이상  : 진중함 +2 / 다정함 +1
            
            [쪽지 내용 → 어조 분석]
            - 이모티콘/ㅋㅋ/ㅎㅎ 다수 : 장난꾸러기 +2
            - 질문형 문장 포함        : 상냥함 +1
            - 위로/응원 표현 포함     : 다정함 +2
            - 사실 정보 전달 위주     : 이성 빠삭 +2
            - 감정 표현 단어 포함     : 감성 촉촉 +2
            - 짧고 단호한 표현        : 과묵함 +1 / 진중함 +1
            
            2. 수식어 선택
            Step 1에서 가장 높은 점수를 받은 수식어 1개를 선택합니다.
            [후보]: 장난꾸러기 / 진중한 / 상냥한 / 다정한 / 과묵한 / 감성 촉촉 / 이성 빠삭
            
            Step 3. 캐릭터 선택
            수식어와 쪽지 전반의 분위기를 조합해 캐릭터 1개를 선택합니다.
            [후보]: 요정 / 산타 / 키다리 아저씨 / 악동 / 곰돌이 / 냥냥이 / 멍멍이
            
            조합 가이드 (참고용, 절대적이지 않음):
            - 따뜻함 계열 (다정한/상냥한)   → 산타, 곰돌이, 키다리 아저씨
            - 장난 계열 (장난꾸러기)         → 악동, 냥냥이, 요정
            - 감성 계열 (감성 촉촉)          → 요정, 냥냥이
            - 분석 계열 (이성 빠삭/진중한)   → 키다리 아저씨, 멍멍이
            - 과묵 계열 (과묵한)             → 고양이형(냥냥이), 곰돌이
            
            Step 4. story 작성 규칙
            - 반드시 시간대, 글자 수, 내용 중 2가지 이상을 구체적 근거로 언급
            - 말투: 위트 있고 가볍게, 단 비하 없이
            - 길이: 1~2문장, 50자 내외
            - 2인칭('당신') 사용 금지, 3인칭 서술
            
            출력 형식
            반드시 JSON만 출력하고, 다른 텍스트는 포함하지 마십시오.
            {"persona": "[수식어] [캐릭터]", "story": "[설명]"}
            
            ## Few-shot 예시
            
            예시 1)
            입력: 쪽지='ㅋㅋ 오늘도 화이팅!! 🔥🔥', 시간대='오전 (6시~12시)', 글자 수='매우 짧음 (15자 이하)'
            출력: {"persona": "장난꾸러기 악동", "story": "새벽도 아닌 오전부터 불꽃 이모티콘을 두 개씩 날리는 사람. 에너지가 남아돌거나, 아니면 그냥 원래 이런 사람이거나."}
            
            예시 2)
            입력: 쪽지='요즘 많이 힘들어 보이던데 뭔가 필요한 거 있으면 말해줘. 나 여기 있어.', 시간대='새벽 (23시~6시)', 글자 수='긺 (41~80자)'
            출력: {"persona": "다정한 키다리 아저씨", "story": "새벽에 이 정도 길이의 쪽지를 보낼 수 있는 사람은 많지 않다. 마니또가 잘 자고 있는지 혼자 걱정하고 있었을 것이다."}
            """;


        String userPrompt = String.format(
                "쪽지 내용: '%s'\n시간대: %s\n글자 수: %s (%d자)",
                noteContent, timeSlot, lengthLabel, length
        );


        String requestBody = """
            {
              "system_instruction": {
                "parts": [
                { "text": "%s" }
                ]
              },
              "contents": [
                {
                  "parts": [
                    { "text": "%s" }
                  ]
                }
              ],
              "generationConfig": {
                "response_mime_type": "application/json",
                "temperature": 0.8
              }
            }
            """.formatted(
                systemPrompt.replace("\"", "\\\"").replace("\n", "\\n"),
                userPrompt.replace("\"", "\\\"").replace("\n", "\\n")
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

            JsonNode root = objectMapper.readTree(response.getBody());
            String jsonContent = root.path("candidates").get(0)
                    .path("content").path("parts").get(0)
                    .path("text").asText();

            
            return objectMapper.readValue(jsonContent, DemoDto.DemoResponse.class);

        } catch (Exception e) {
            e.printStackTrace();
            return new DemoDto.DemoResponse("오류 발생 요정", "AI 서버와 통신 중 문제가 생겼습니다.");
        }
    }
}
