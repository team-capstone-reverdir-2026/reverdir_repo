/// GET /rooms/{roomId}/questions/today — TodayQuestion UI 모델.
///
/// TODO: [HintRepository.fetchTodayQuestion] 연동 후 fromJson 팩토리 추가
class TodayQuestionViewData {
  const TodayQuestionViewData({
    required this.questionId,
    required this.content,
    required this.date,
    this.myAnswered = false,
    this.myAnswerContent,
    this.manittoAnswered = false,
    this.manittoAnswerContent,
    this.manittoVisibleToMe = false,
  });

  final String questionId;
  final String content;
  final String date;
  final bool myAnswered;
  final String? myAnswerContent;
  final bool manittoAnswered;
  final String? manittoAnswerContent;

  /// API: manitoAnswer.visibleToMe
  final bool manittoVisibleToMe;

  bool get shouldBlurManittoAnswer =>
      manittoAnswered && !myAnswered && !manittoVisibleToMe;

  TodayQuestionViewData copyWith({
    String? questionId,
    String? content,
    String? date,
    bool? myAnswered,
    String? myAnswerContent,
    bool? manittoAnswered,
    String? manittoAnswerContent,
    bool? manittoVisibleToMe,
  }) {
    return TodayQuestionViewData(
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      date: date ?? this.date,
      myAnswered: myAnswered ?? this.myAnswered,
      myAnswerContent: myAnswerContent ?? this.myAnswerContent,
      manittoAnswered: manittoAnswered ?? this.manittoAnswered,
      manittoAnswerContent: manittoAnswerContent ?? this.manittoAnswerContent,
      manittoVisibleToMe: manittoVisibleToMe ?? this.manittoVisibleToMe,
    );
  }

  factory TodayQuestionViewData.mock() => const TodayQuestionViewData(
        questionId: 'q_mock',
        content: '당신이 가장 좋아하는 겨울 간식은 무엇인가요?',
        date: '2026-05-25',
        myAnswered: false,
        myAnswerContent: '당연히 붕어빵이죠! 팥 붕어빵 최고 🐟',
        manittoAnswered: true,
        manittoAnswerContent: '군고구마랑 동치미 조합이 최고입니다',
        manittoVisibleToMe: false,
      );

  factory TodayQuestionViewData.fromApiJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return TodayQuestionViewData.mock();
    }

    final my = json['myAnswer'] as Map<String, dynamic>?;
    final manito = json['manitoAnswer'] as Map<String, dynamic>?;

    final questionId = json['questionId'] as String?;
    final content = json['content'] as String?;
    final date = json['date'] as String?;
    final hasNoQuestionData =
        (questionId == null || questionId.trim().isEmpty) &&
            (content == null || content.trim().isEmpty) &&
            (date == null || date.trim().isEmpty);

    if (hasNoQuestionData) {
      return TodayQuestionViewData.mock();
    }

    return TodayQuestionViewData(
      questionId: questionId ?? TodayQuestionViewData.mock().questionId,
      content: content ?? TodayQuestionViewData.mock().content,
      date: date ?? TodayQuestionViewData.mock().date,
      myAnswered: my?['answered'] as bool? ?? false,
      myAnswerContent: my?['content'] as String?,
      manittoAnswered: manito?['answered'] as bool? ?? false,
      manittoAnswerContent: manito?['content'] as String?,
      manittoVisibleToMe: manito?['visibleToMe'] as bool? ?? false,
    );
  }

  /// GameMainScreen debug 플래그용
  TodayQuestionViewData copyWithDebug({
    bool? myAnswered,
    bool? manittoAnswered,
  }) {
    final my = myAnswered ?? this.myAnswered;
    final man = manittoAnswered ?? this.manittoAnswered;
    return TodayQuestionViewData(
      questionId: questionId,
      content: content,
      date: date,
      myAnswered: my,
      myAnswerContent:
          my ? (myAnswerContent ?? '당연히 붕어빵이죠! 팥 붕어빵 최고 🐟') : null,
      manittoAnswered: man,
      manittoAnswerContent:
          man ? (manittoAnswerContent ?? '군고구마랑 동치미 조합이 최고입니다') : null,
      manittoVisibleToMe: my && man,
    );
  }
}
