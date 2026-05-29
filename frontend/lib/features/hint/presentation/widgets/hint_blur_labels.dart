/// [HintBlur] 칩 문구 — 호출부에서 상황별로 명시해 사용.
abstract final class HintBlurLabels {
  HintBlurLabels._();

  static const String todayManittoAnswered =
      '마니또가 답변했어요! (보고 싶다면 답장해 주세요)';

  /// 과거 질문 · 내가 그날 답하지 않음 · 마니또 답은 history API로 확인 불가.
  static const String pastDayWithoutMyAnswer =
      '답변하지 않은 날의 답변은 볼 수 없어요.';
}
