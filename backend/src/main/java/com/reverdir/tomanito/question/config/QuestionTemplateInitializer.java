package com.reverdir.tomanito.question.config;

import com.reverdir.tomanito.question.domain.QuestionTemplate;
import com.reverdir.tomanito.question.repository.QuestionTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class QuestionTemplateInitializer implements ApplicationRunner {

    private static final List<String> SEED_QUESTIONS = List.of(
            "당신이 가장 좋아하는 계절은?",
            "최근에 읽은 책은?",
            "스트레스를 풀 때 하는 일은?",
            "가장 기억에 남는 여행지는?",
            "주말에 가장 하고 싶은 일은?",
            "어릴 적 꿈은 무엇이었나요?",
            "요즘 즐겨 듣는 노래 장르는?",
            "가장 좋아하는 음식은?",
            "휴식을 취할 때 선호하는 방식은?",
            "최근에 감동받은 순간은?",
            "하루 중 가장 좋아하는 시간대는?",
            "최근에 새롭게 시작한 취미는?",
            "가장 좋아하는 영화 장르는?",
            "혼자 있을 때 주로 무엇을 하나요?",
            "가장 자주 사용하는 이모지는?",
            "지금 가장 가고 싶은 나라는?",
            "어렸을 때 가장 좋아했던 만화는?",
            "평생 한 가지 음식만 먹어야 한다면?",
            "비 오는 날 가장 하고 싶은 일은?",
            "최근 가장 많이 웃었던 순간은?",
            "카페에 가면 주로 무엇을 주문하나요?",
            "가장 좋아하는 향기는?",
            "요즘 가장 관심 있는 분야는?",
            "하루 동안 휴대폰 없이 지낼 수 있나요?",
            "가장 좋아하는 계절의 이유는?",
            "최근에 본 드라마 중 추천하고 싶은 것은?",
            "친구들이 나를 한 단어로 표현한다면?",
            "아침형 인간 vs 밤형 인간?",
            "가장 좋아하는 디저트는?",
            "무인도에 하나만 가져갈 수 있다면?",
            "최근에 도전해보고 싶은 일이 생겼나요?",
            "자주 사용하는 음악 플레이리스트 분위기는?",
            "가장 좋아하는 색깔과 그 이유는?",
            "쉬는 날 집순이/집돌이 스타일인가요?",
            "학창 시절 가장 좋아했던 과목은?",
            "최근에 가장 만족했던 소비는?",
            "반려동물을 키운다면 어떤 동물을 키우고 싶나요?",
            "가장 좋아하는 날씨는?",
            "오늘 당장 떠날 수 있다면 어디로 가고 싶나요?",
            "나를 가장 편안하게 만드는 장소는?"
    );

    private final QuestionTemplateRepository questionTemplateRepository;

    @Override
    public void run(ApplicationArguments args) {
        if (questionTemplateRepository.count() > 0) {
            return;
        }

        SEED_QUESTIONS.forEach(content ->
                questionTemplateRepository.save(QuestionTemplate.builder().content(content).build())
        );
    }
}
