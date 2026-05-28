/// GET /rooms/{roomId}/questions/today — TodayQuestion UI 모델.
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

  factory TodayQuestionViewData.fromApiJson(Map<String, dynamic> json) {
    final my = json['myAnswer'] as Map<String, dynamic>?;
    final manito = json['manitoAnswer'] as Map<String, dynamic>?;

    return TodayQuestionViewData(
      questionId: json['questionId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      date: json['date'] as String? ?? '',
      myAnswered: my?['answered'] as bool? ?? false,
      myAnswerContent: my?['content'] as String?,
      manittoAnswered: manito?['answered'] as bool? ?? false,
      manittoAnswerContent: manito?['content'] as String?,
      manittoVisibleToMe: manito?['visibleToMe'] as bool? ?? false,
    );
  }

}
