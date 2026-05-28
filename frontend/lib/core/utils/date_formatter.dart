import 'package:intl/intl.dart';

/// doc/api-docs.json 날짜 필드 포맷 유틸.
///
/// - `date-time`: Mission.createdAt, Note.sentAt, RoomDetail.endsAt
/// - `date`: TodayQuestion.date, QuestionHistoryItem.date
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayDateTime = DateFormat('M월 d일 HH:mm');
  static final DateFormat _displayDate = DateFormat('M월 d일');
  static final DateFormat _displayTime = DateFormat('HH:mm');

  /// ISO 8601 → "5월 21일 18:00"
  ///
  /// 예: `2026-05-21T18:00:00+09:00`, `2026-05-21T18:00:00Z`
  static String formatIso8601(String? iso8601, {String fallback = '-'}) {
    if (iso8601 == null || iso8601.isEmpty) return fallback;
    try {
      final dt = DateTime.parse(iso8601).toLocal();
      return _displayDateTime.format(dt);
    } catch (_) {
      return fallback;
    }
  }

  /// API `date` (YYYY-MM-DD) → "5월 21일"
  static String formatApiDate(String? date, {String fallback = '-'}) {
    if (date == null || date.isEmpty) return fallback;
    try {
      final dt = DateTime.parse(date);
      return _displayDate.format(dt);
    } catch (_) {
      return fallback;
    }
  }

  /// Note.sentAt 등 상대 표현 — 오늘은 시간만, 그 외는 날짜+시간
  static String formatRelative(String? iso8601, {String fallback = '-'}) {
    if (iso8601 == null || iso8601.isEmpty) return fallback;
    try {
      final dt = DateTime.parse(iso8601).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(dt.year, dt.month, dt.day);

      if (target == today) {
        return '오늘 ${_displayTime.format(dt)}';
      }
      if (target == today.subtract(const Duration(days: 1))) {
        return '어제 ${_displayTime.format(dt)}';
      }
      return _displayDateTime.format(dt);
    } catch (_) {
      return fallback;
    }
  }

  /// RoomDetail.daysRemaining 보조 — endsAt까지 D-day 스타일
  ///
  /// TODO: 타임존 정책 확정 시 서버 기준 일자 계산으로 교체
  static String formatDaysRemaining(DateTime? endsAt) {
    if (endsAt == null) return '';
    final diff = endsAt.toLocal().difference(DateTime.now());
    final days = diff.inDays;
    if (days < 0) return '종료됨';
    if (days == 0) return '오늘 마감';
    return 'D-$days';
  }
}
