package com.reverdir.tomanito.global.initializer;

import com.reverdir.tomanito.mission.domain.Mission;
import com.reverdir.tomanito.mission.repository.MissionRepository;
import com.reverdir.tomanito.note.domain.Note;
import com.reverdir.tomanito.note.repository.NoteRepository;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.question.domain.Answer;
import com.reverdir.tomanito.question.domain.Question;
import com.reverdir.tomanito.question.repository.AnswerRepository;
import com.reverdir.tomanito.question.repository.QuestionRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import com.reverdir.tomanito.user.domain.User;
import com.reverdir.tomanito.user.repository.UserRepository;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;

@Component
@RequiredArgsConstructor
public class TestDataInitializer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;
    private final EntityManager em;

    private final UserRepository userRepository;
    private final QuestionRepository  questionRepository;
    private final MissionRepository missionRepository;
    private final ParticipantRepository  participantRepository;
    private final RoomRepository roomRepository;
    private final NoteRepository noteRepository;
    private final AnswerRepository answerRepository;

    @Transactional
    public void run(String... args) throws Exception {

        if (userRepository.findByUsername("aaaa").isPresent()) {
            return;
        }

        LocalDateTime fourDaysAgo = LocalDateTime.now().minusDays(4);
        OffsetDateTime fourDaysAgoOffset = OffsetDateTime.now().minusDays(4);
        OffsetDateTime endsAtOffset = OffsetDateTime.now().plusDays(40);

        // 유저 3명 생성
        String hashedPassword = BCrypt.hashpw("1234", BCrypt.gensalt());

        // 테스트 유저 생성 시 암호화된 비밀번호를 주입합니다.
        User testUserA = userRepository.save(User.builder().name("지연").username("aaaa").password(hashedPassword).build());
        User testUserB = userRepository.save(User.builder().name("시우").username("bbbb").password(hashedPassword).build());
        User testUserC = userRepository.save(User.builder().name("예은").username("cccc").password(hashedPassword).build());
        // 방 생성 (4일 전 시작)
        Room room = roomRepository.save(Room.builder()
                .name("우리 과 모여라")
                .description("삼총사끼리 마니또 한 판")
                .status(RoomStatus.IN_PROGRESS)
                .inviteCode("000000")
                .endsAt(endsAtOffset)
                .missionCount(3)
                .host(testUserA)
                .build());
        room.start(fourDaysAgoOffset);

        // 참여자 생성
        Participant partA = participantRepository.save(Participant.builder().room(room).user(testUserA).displayName("지연").isHost(true).build());
        Participant partB = participantRepository.save(Participant.builder().room(room).user(testUserB).displayName("시우").isHost(false).build());
        Participant partC = participantRepository.save(Participant.builder().room(room).user(testUserC).displayName("예은").isHost(false).build());

        // 마니또 관계 설정 (지연 -> 시우 -> 예은 -> 지연)
        // 예은(C) -> 나 -> 시우(B)
        partA.assignManitti(partB);
        partB.assignManitti(partC);
        partC.assignManitti(partA);

        // 미션 생성
        missionRepository.save(Mission.builder().room(room).participant(partA).content("상대가 오늘 꼭 웃게 만들기").build());
        missionRepository.save(Mission.builder().room(room).participant(partA).content("재미있는 밈이나 영상 보내주기").build());
        missionRepository.save(Mission.builder().room(room).participant(partA).content("따뜻한 차 한 잔 마시라고 전하기").build());

        // 나에게 온 읽지 않은 쪽지 (내 마니또인 C가 보냄)
        Note note = noteRepository.save(Note.builder().room(room).sender(partC).receiver(partA).content("오늘 하루도 파이팅~ ^ㅡ^").build());
        Note note2 = noteRepository.save(Note.builder().room(room).sender(partC).receiver(partA).content("요즘 시험기간이라 힘들지 ㅠㅠ 바빠도 쉬엄쉬업 해!").build());

        // 힌트 질문 4개 생성 (4일 전, 3일 전, 2일 전, 1일 전)
        Question q1 = questionRepository.save(Question.builder().room(room).content("나의 첫인상은 어떤 느낌?").questionDate(LocalDate.now().minusDays(3)).build());
        Question q2 = questionRepository.save(Question.builder().room(room).content("요즘 가장 좋아하는 음식은?").questionDate(LocalDate.now().minusDays(2)).build());
        Question q3 = questionRepository.save(Question.builder().room(room).content("무인도에 하나만 가져갈 수 있다면?").questionDate(LocalDate.now().minusDays(1)).build());
        Question q4 = questionRepository.save(Question.builder().room(room).content("최근에 가장 만족했던 소비는?").questionDate(LocalDate.now()).build());

        // 답변 상태 세팅 (나: partA, 내 마니또: partC)
        answerRepository.save(Answer.builder().participant(partC).question(q1).content("조용하고 도도하다는 말 자주 들음. 약간 시크한 타입?").build());

        answerRepository.save(Answer.builder().participant(partA).question(q2).content("마라탕. 얼린 두부는 꼭 넣어야 해!").build());

        // 상태 3 & 4: 둘 다 답한 상태 (Q3, Q4)
        answerRepository.save(Answer.builder().participant(partA).question(q3).content("잠은 소중하니까 매트리스~~").build());
        answerRepository.save(Answer.builder().participant(partC).question(q3).content("안 가고 싶음... 가야만 한다면 맥가이버 칼.").build());

        answerRepository.save(Answer.builder().participant(partA).question(q4).content("베개를 샀는데 베자마자 잠들었다 푹신푹신").build());
        answerRepository.save(Answer.builder().participant(partC).question(q4).content("세일하던 아디다스 운동화.").build());

        em.flush();
        em.clear();

        // JPA Auditing 우회
        // Room, Notes, Questions, Answers 테이블의 생성 시간을 4일 전으로 일괄 변경
        jdbcTemplate.update("UPDATE rooms SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE notes SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE questions SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE answers SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);

    }
}
