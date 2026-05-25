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
            "최근에 감동받은 순간은?"
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
