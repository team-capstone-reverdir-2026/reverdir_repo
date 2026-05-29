import 'package:flutter/material.dart';

import '../../../hint/provider/hint_provider.dart';
import '../../../manitto_game/data/game_repository.dart';
import 'hint_blur.dart';
import 'hint_blur_labels.dart';

/// 힌트 모음 — 마니또 답변 영역 (history + 오늘 질문 today API 보조).
class HistoryManittoAnswer extends StatelessWidget {
  const HistoryManittoAnswer({
    super.key,
    required this.item,
    this.todayQuestion,
    required this.answerBlockBuilder,
  });

  final QuestionHistoryData item;
  final TodayQuestionViewData? todayQuestion;
  final Widget Function(String content) answerBlockBuilder;

  bool get _isToday {
    final todayDate = todayQuestion?.date.trim();
    if (todayDate == null || todayDate.isEmpty) return false;
    return item.date.trim() == todayDate;
  }

  bool get _myAnswered {
    final mine = item.myAnswer?.trim();
    return mine != null && mine.isNotEmpty;
  }

  bool get _manittoHasVisibleContent {
    final answer = item.manittoAnswer?.trim();
    return answer != null && answer.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bubble = answerBlockBuilder(_resolveContent());
    final mode = _resolveMode();

    return switch (mode) {
      _ManittoDisplayMode.blurToday => HintBlur(
          chipLabel: HintBlurLabels.todayManittoAnswered,
          child: bubble,
        ),
      _ManittoDisplayMode.blurPast => HintBlur(
          chipLabel: HintBlurLabels.pastDayWithoutMyAnswer,
          child: bubble,
        ),
      _ManittoDisplayMode.plain => bubble,
    };
  }

  _ManittoDisplayMode _resolveMode() {
    if (_myAnswered) return _ManittoDisplayMode.plain;

    if (_isToday) {
      final manittoAnswered = todayQuestion?.manittoAnswered ?? false;
      return manittoAnswered
          ? _ManittoDisplayMode.blurToday
          : _ManittoDisplayMode.plain;
    }

    // 과거 · 내 미답변: history API는 마니또 답변 여부를 주지 않음.
    // 마니또가 답한 날은 내용이 내려오지 않으므로, 미답변 과거일은 열람 차단 블러로 처리.
    return _ManittoDisplayMode.blurPast;
  }

  String _resolveContent() {
    if (_myAnswered) {
      if (_manittoHasVisibleContent) {
        return item.manittoAnswer!.trim();
      }
      return _isToday
          ? '마니또가 고민 중이에요.'
          : '마니또가 답변하지 않았어요.';
    }

    if (_isToday) {
      final manittoAnswered = todayQuestion?.manittoAnswered ?? false;
      if (!manittoAnswered) {
        return '마니또가 고민 중이에요.';
      }
      return todayQuestion?.manittoAnswerContent?.trim() ?? '';
    }

    return '';
  }
}

enum _ManittoDisplayMode {
  plain,
  blurToday,
  blurPast,
}
