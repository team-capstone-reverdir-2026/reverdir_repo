import '../../../core/utils/json_parse.dart';

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
    final my = parseJsonMap(json['myAnswer']);
    final manito = parseJsonMap(json['manitoAnswer']);

    return TodayQuestionViewData(
      questionId: parseJsonString(json['questionId']),
      content: parseJsonString(json['content']),
      date: parseJsonString(json['date']),
      myAnswered: parseJsonBool(my?['answered']),
      myAnswerContent: my?['content'] == null
          ? null
          : parseJsonString(my?['content']),
      manittoAnswered: parseJsonBool(manito?['answered']),
      manittoAnswerContent: manito?['content'] == null
          ? null
          : parseJsonString(manito?['content']),
      manittoVisibleToMe: parseJsonBool(manito?['visibleToMe']),
    );
  }

}
