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
import java.util.List;

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

        // 유저 생성
        String hashedPassword = BCrypt.hashpw("1234", BCrypt.gensalt());

        User testUserA = userRepository.save(User.builder().name("지연").username("aaaa").password(hashedPassword).build());
        User testUserB = userRepository.save(User.builder().name("시우").username("bbbb").password(hashedPassword).build());
        User testUserC = userRepository.save(User.builder().name("예은").username("cccc").password(hashedPassword).build());


        Room room1 = roomRepository.save(Room.builder().name("우리 과 모여라").description("삼총사끼리 마니또 한 판").status(RoomStatus.IN_PROGRESS).inviteCode("000000").endsAt(endsAtOffset).missionCount(3).host(testUserA).build());
        room1.start(fourDaysAgoOffset);
        List<String> missions1 = List.of("상대가 오늘 꼭 웃게 만들기", "재미있는 밈이나 영상 보내주기", "따뜻한 차 한 잔 마시라고 전하기");
        setupRoomData(room1, testUserA, testUserB, testUserC, missions1, "오늘 하루도 파이팅~ ^ㅡ^", 1);

        Room room2 = roomRepository.save(Room.builder().name("2026 배드민턴 부 마니또").description("팡팡").status(RoomStatus.IN_PROGRESS).inviteCode("111111").endsAt(endsAtOffset).missionCount(2).host(testUserA).build());
        room2.start(fourDaysAgoOffset);
        List<String> missions2 = List.of("라켓 몰래 닦아주기", "이온음료 기프티콘 보내기");
        setupRoomData(room2, testUserA, testUserB, testUserC, missions2, "오늘 스매싱 최고였어!", 2);

        Room room3 = roomRepository.save(Room.builder().name("테일즈런너 마스터들").description("더블 점프").status(RoomStatus.IN_PROGRESS).inviteCode("222222").endsAt(endsAtOffset).missionCount(4).host(testUserA).build());
        room3.start(fourDaysAgoOffset);
        List<String> missions3 = List.of("같이 달리기", "응원 메시지 보내기", "아이템 선물하기", "비밀글 남기기");
        setupRoomData(room3, testUserA, testUserB, testUserC, missions3, "빨리 접속하세요", 3);


        // JPA 캐시 비우기
        em.flush();
        em.clear();

        // JPA Auditing 우회
        jdbcTemplate.update("UPDATE rooms SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE notes SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE questions SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);
        jdbcTemplate.update("UPDATE answers SET created_at = ?, updated_at = ?", fourDaysAgo, fourDaysAgo);

    }

    // helper method
    private void setupRoomData(Room room, User userA, User userB, User userC, List<String> missionList, String noteMessage, int n) {

        Participant partA = participantRepository.save(Participant.builder().room(room).user(userA).displayName("지연").isHost(true).build());
        Participant partB = participantRepository.save(Participant.builder().room(room).user(userB).displayName("시우").isHost(false).build());
        Participant partC = participantRepository.save(Participant.builder().room(room).user(userC).displayName("예은").isHost(false).build());

        for (String missionContent : missionList) {
            missionRepository.save(Mission.builder().room(room).participant(partA).content(missionContent).build());
        }

        noteRepository.save(Note.builder().room(room).sender(partC).receiver(partA).content(noteMessage).build());

        if (n == 1) {
            partA.assignManitti(partB);
            partB.assignManitti(partC);
            partC.assignManitti(partA);

            noteRepository.save(Note.builder().room(room).sender(partC).receiver(partA).content("요즘 시험기간이라 힘들지 ㅠㅠ 바빠도 쉬엄쉬업 해!").build());

            Question q1 = questionRepository.save(Question.builder().room(room).content("나의 첫인상은 어떤 느낌?").questionDate(LocalDate.now().minusDays(3)).build());
            Question q2 = questionRepository.save(Question.builder().room(room).content("요즘 가장 좋아하는 음식은?").questionDate(LocalDate.now().minusDays(2)).build());
            Question q3 = questionRepository.save(Question.builder().room(room).content("무인도에 하나만 가져갈 수 있다면?").questionDate(LocalDate.now().minusDays(1)).build());
            Question q4 = questionRepository.save(Question.builder().room(room).content("최근에 가장 만족했던 소비는?").questionDate(LocalDate.now()).build());

            answerRepository.save(Answer.builder().participant(partC).question(q1).content("조용하고 도도하다는 말 자주 들음. 약간 시크한 타입?").build());

            answerRepository.save(Answer.builder().participant(partA).question(q2).content("마라탕. 얼린 두부는 꼭 넣어야 해!").build());

            answerRepository.save(Answer.builder().participant(partA).question(q3).content("잠은 소중하니까 매트리스~~").build());
            answerRepository.save(Answer.builder().participant(partC).question(q3).content("가야만 한다면 맥가이버 칼.").build());

            answerRepository.save(Answer.builder().participant(partA).question(q4).content("베개를 샀는데 베자마자 잠들었다 푹신푹신").build());
            answerRepository.save(Answer.builder().participant(partC).question(q4).content("세일하던 아디다스 운동화.").build());

        } else if (n == 2) {
            partA.assignManitti(partC);
            partC.assignManitti(partB);
            partB.assignManitti(partA);

            Question q1 = questionRepository.save(Question.builder().room(room).content("하루 중 가장 좋아하는 시간대는?").questionDate(LocalDate.now().minusDays(1)).build());
            Question q2 = questionRepository.save(Question.builder().room(room).content("어릴 적 꿈은 무엇이었나요?").questionDate(LocalDate.now()).build());

            answerRepository.save(Answer.builder().participant(partA).question(q1).content("자정! 날짜가 바뀌는 날~").build());
            answerRepository.save(Answer.builder().participant(partB).question(q2).content("달에 가고 싶었어~").build());
        } else if (n == 3) {
            partA.assignManitti(partB);
            partB.assignManitti(partC);
            partC.assignManitti(partA);

            Question q1 = questionRepository.save(Question.builder().room(room).content("가장 자주 사용하는 이모지는?").questionDate(LocalDate.now().minusDays(1)).build());
            Question q2 = questionRepository.save(Question.builder().room(room).content("요즘 즐겨 듣는 노래 장르는?").questionDate(LocalDate.now()).build());

            answerRepository.save(Answer.builder().participant(partC).question(q1).content("^ㅡㅡㅡ^").build());
            answerRepository.save(Answer.builder().participant(partA).question(q2).content("새벽에 발라드 듣는 거에 빠졌어~").build());
        }
    }
}
