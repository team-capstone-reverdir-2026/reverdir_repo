package com.reverdir.tomanito.mission.config;

import com.reverdir.tomanito.mission.domain.MissionTemplate;
import com.reverdir.tomanito.mission.repository.MissionTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class MissionTemplateInitializer implements ApplicationRunner {

    private static final List<String> SEED_QUESTIONS = List.of(
            "손 잡고 사진 한 장 찍기",
            "상대를 닮은 캐릭터 그림 그려주기",
            "몰래 간식 사서 책상 위에 두기",
            "칭찬 3가지 적어서 전달하기",
            "상대가 좋아할 만한 노래 추천해주기",
            "함께 셀카 찍기",
            "짧은 손편지 써주기",
            "하루 동안 상대 별명으로 부르기",
            "재미있는 밈이나 영상 보내주기",
            "상대 취향 음료 맞혀서 선물하기",
            "응원 메시지 익명으로 남기기",
            "상대의 장점 하나를 다른 사람들에게 말해주기",
            "함께 점심 또는 간식 먹기",
            "상대를 위한 짧은 시 쓰기",
            "상대가 좋아할 것 같은 사진 찍어서 보내기",
            "상대 이름으로 삼행시 만들기",
            "몰래 책상 정리 도와주기",
            "함께 산책하기",
            "상대와 공통점 5개 찾기",
            "귀여운 스티커나 이모티콘 선물하기",
            "상대가 좋아하는 음악 장르 플레이리스트 만들어주기",
            "똑같은 포즈로 함께 사진 찍기",
            "상대에게 어울리는 영화/드라마 캐릭터 골라주기",
            "초성 퀴즈 만들어서 내기",
            "상대가 오늘 꼭 웃게 만들기",
            "간단한 간식이나 커피 사주기",
            "상대를 주인공으로 한 짧은 소개글 써주기",
            "함께 게임 한 판 하기",
            "상대가 좋아할 만한 명언이나 문장 보내주기"
    );

    private final MissionTemplateRepository missionTemplateRepository;

    @Override
    public void run(ApplicationArguments args) {
        if (missionTemplateRepository.count() > 0) {
            return;
        }

        SEED_QUESTIONS.forEach(content ->
                missionTemplateRepository.save(MissionTemplate.builder().content(content).build())
        );
    }
}