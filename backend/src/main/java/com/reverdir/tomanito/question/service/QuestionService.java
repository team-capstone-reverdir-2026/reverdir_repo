package com.reverdir.tomanito.question.service;

import com.reverdir.tomanito.global.error.CustomException;
import com.reverdir.tomanito.global.error.ErrorCode;
import com.reverdir.tomanito.participant.domain.Participant;
import com.reverdir.tomanito.participant.repository.ParticipantRepository;
import com.reverdir.tomanito.question.domain.Answer;
import com.reverdir.tomanito.question.domain.Question;
import com.reverdir.tomanito.question.domain.QuestionTemplate;
import com.reverdir.tomanito.question.dto.AnswerResponse;
import com.reverdir.tomanito.question.dto.ManitoAnswerDto;
import com.reverdir.tomanito.question.dto.MyAnswerDto;
import com.reverdir.tomanito.question.dto.QuestionHistoryItem;
import com.reverdir.tomanito.question.dto.QuestionHistoryResponse;
import com.reverdir.tomanito.question.dto.SubmitAnswerRequest;
import com.reverdir.tomanito.question.dto.TodayQuestionResponse;
import com.reverdir.tomanito.question.repository.AnswerRepository;
import com.reverdir.tomanito.question.repository.QuestionRepository;
import com.reverdir.tomanito.question.repository.QuestionTemplateRepository;
import com.reverdir.tomanito.room.domain.Room;
import com.reverdir.tomanito.room.domain.RoomStatus;
import com.reverdir.tomanito.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private static final ZoneId ZONE_SEOUL = ZoneId.of("Asia/Seoul");

    private final QuestionRepository questionRepository;
    private final QuestionTemplateRepository questionTemplateRepository;
    private final AnswerRepository answerRepository;
    private final ParticipantRepository participantRepository;
    private final RoomRepository roomRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public TodayQuestionResponse getTodayQuestion(Long userId, Long roomId) {
        Participant participant = getParticipantInProgressGame(userId, roomId);
        Room room = participant.getRoom();
        LocalDate today = LocalDate.now(ZONE_SEOUL);

        Question question = getOrCreateTodayQuestion(room, today);
        Optional<Participant> manitto = findManitto(roomId, participant.getId());

        MyAnswerDto myAnswer = buildMyAnswer(participant.getId(), question.getId());
        ManitoAnswerDto manitoAnswer = buildManitoAnswer(manitto, question.getId(), myAnswer.answered());

        return TodayQuestionResponse.of(question, myAnswer, manitoAnswer);
    }

    @Transactional
    public AnswerResponse submitAnswer(Long userId, Long roomId, SubmitAnswerRequest request) {
        Participant participant = getParticipantInProgressGame(userId, roomId);
        Room room = participant.getRoom();
        LocalDate today = LocalDate.now(ZONE_SEOUL);

        Question question = getOrCreateTodayQuestion(room, today);

        Answer answer = answerRepository.findByParticipantIdAndQuestionId(participant.getId(), question.getId())
                .map(existing -> {
                    existing.updateContent(request.content());
                    return existing;
                })
                .orElseGet(() -> answerRepository.save(Answer.builder()
                        .participant(participant)
                        .question(question)
                        .content(request.content())
                        .build()));

        return AnswerResponse.from(answer);
    }

    @Transactional(readOnly = true)
    public QuestionHistoryResponse getQuestionHistory(Long userId, Long roomId) {
        Participant participant = getParticipantInProgressGame(userId, roomId);
        LocalDate today = LocalDate.now(ZONE_SEOUL);

        List<Question> questions = questionRepository
                .findAllByRoomIdAndQuestionDateLessThanEqualOrderByQuestionDateDesc(roomId, today);

        Optional<Participant> manitto = findManitto(roomId, participant.getId());

        List<Long> questionIds = questions.stream().map(Question::getId).toList();
        Map<Long, Answer> myAnswers = loadAnswersByQuestionIds(participant.getId(), questionIds);
        Map<Long, Answer> manittoAnswers = manitto
                .map(m -> loadAnswersByQuestionIds(m.getId(), questionIds))
                .orElse(Map.of());

        List<QuestionHistoryItem> history = questions.stream()
                .map(question -> toHistoryItem(question, myAnswers, manittoAnswers))
                .toList();

        return new QuestionHistoryResponse(history);
    }

    private Question getOrCreateTodayQuestion(Room room, LocalDate today) {
        return questionRepository.findByRoomIdAndQuestionDate(room.getId(), today)
                .orElseGet(() -> {
                    QuestionTemplate template = selectRandomTemplate(room.getId());
                    return questionRepository.save(Question.builder()
                            .room(room)
                            .content(template.getContent())
                            .questionDate(today)
                            .questionTemplate(template)
                            .build());
                });
    }

    private QuestionTemplate selectRandomTemplate(Long roomId) {
        List<Long> usedTemplateIds = questionRepository.findUsedTemplateIdsByRoomId(roomId);

        List<QuestionTemplate> candidates = usedTemplateIds.isEmpty()
                ? questionTemplateRepository.findAll()
                : questionTemplateRepository.findAllByIdNotIn(usedTemplateIds);

        if (candidates.isEmpty()) {
            candidates = questionTemplateRepository.findAll();
        }

        if (candidates.isEmpty()) {
            throw new CustomException(ErrorCode.NOT_FOUND);
        }

        return candidates.get(secureRandom.nextInt(candidates.size()));
    }

    private Participant getParticipantInProgressGame(Long userId, Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        if (room.getStatus() != RoomStatus.IN_PROGRESS) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return participantRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new CustomException(ErrorCode.FORBIDDEN));
    }

    private Optional<Participant> findManitto(Long roomId, Long myParticipantId) {
        return participantRepository.findByRoomIdAndManittiId(roomId, myParticipantId);
    }

    private MyAnswerDto buildMyAnswer(Long participantId, Long questionId) {
        return answerRepository.findByParticipantIdAndQuestionId(participantId, questionId)
                .map(answer -> MyAnswerDto.of(answer.getContent()))
                .orElseGet(MyAnswerDto::notAnswered);
    }

    private ManitoAnswerDto buildManitoAnswer(
            Optional<Participant> manitto,
            Long questionId,
            boolean myAnswered
    ) {
        if (manitto.isEmpty()) {
            return ManitoAnswerDto.notAnswered();
        }

        Optional<Answer> manittoAnswer = answerRepository.findByParticipantIdAndQuestionId(
                manitto.get().getId(),
                questionId
        );

        if (manittoAnswer.isEmpty()) {
            return ManitoAnswerDto.notAnswered();
        }

        if (!myAnswered) {
            return ManitoAnswerDto.hidden(true);
        }

        return ManitoAnswerDto.visible(manittoAnswer.get().getContent());
    }

    private Map<Long, Answer> loadAnswersByQuestionIds(Long participantId, List<Long> questionIds) {
        if (questionIds.isEmpty()) {
            return Map.of();
        }
        return answerRepository.findAllByParticipantIdAndQuestionIdIn(participantId, questionIds).stream()
                .collect(Collectors.toMap(answer -> answer.getQuestion().getId(), Function.identity()));
    }

    private QuestionHistoryItem toHistoryItem(
            Question question,
            Map<Long, Answer> myAnswers,
            Map<Long, Answer> manittoAnswers
    ) {
        Answer myAnswer = myAnswers.get(question.getId());
        boolean isBlurred = myAnswer == null;

        String myAnswerContent = myAnswer != null ? myAnswer.getContent() : null;
        String manitoAnswerContent = null;
        if (!isBlurred) {
            Answer manittoAnswer = manittoAnswers.get(question.getId());
            manitoAnswerContent = manittoAnswer != null ? manittoAnswer.getContent() : null;
        }

        return new QuestionHistoryItem(
                question.getQuestionDate(),
                question.getContent(),
                myAnswerContent,
                manitoAnswerContent,
                isBlurred
        );
    }
}
