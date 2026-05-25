
import 'package:flutter/material.dart';

import '../network/api_enums.dart';

/// Manitto API(doc/api-docs.json) 도메인별 파스텔 팔레트.
///
/// UI 상태 색은 [roomStatusBackground] 등 시맨틱 헬퍼를 사용해
/// OpenAPI enum과 1:1로 맞춥니다.
class AppColors {
  // 생성자를 private으로 만들어 인스턴스화(new AppColors())를 방지합니다.
  AppColors._();

  // ── 브랜드·포인트 (Auth CTA, Game start 등) ─────────────────────────────
  /// CRed — 로그인·핵심 CTA · ErrorResponse 강조
  static const Color CRed = Color(0xFFFF7F7A);

  // ── Rooms / Game — RoomStatus IN_PROGRESS, 미션 진행 ─────────────────────
  /// COrange — 진행 중 뱃지 · MyReport PENDING 폴링
  static const Color COrange = Color(0xFFFFB347);

  // ── DailyQuestions — TodayQuestion 카드 ─────────────────────────────────
  /// CYellow — 오늘의 질문 카드 · RoomStatus WAITING
  static const Color CYellow = Color(0xFFFFD966);

  // ── Missions — Mission.isCompleted ──────────────────────────────────────
  /// CGreen — 미션 완료 체크
  static const Color CGreen = Color(0xFFA8E6B0);

  // ── Notes — 쪽지함 · 네비 ───────────────────────────────────────────────
  /// CSkyBlue — Note RECEIVED · 네비 활성
  static const Color CSkyBlue = Color(0xFF7DD9D4);

  // ── Participants — Participant.displayName 아바타 ───────────────────────
  /// CBlue — 참여자 아바타 · manitoAnswer visibleToMe=false 블러 힌트
  static const Color CBlue = Color(0xFF9BB8F5);

  // ── Results — MyReport READY, ManittoReveal ─────────────────────────────
  /// CPurple — 결과 유형 카드 · 리포트 준비 완료
  static const Color CPurple = Color(0xFFC8A9E8);

  // ── Notes / my-manitti — 쪽지·마니띠 카드 ─────────────────────────────
  /// CPink — Note 작성 · 나의 마니띠 섹션
  static const Color CPink = Color(0xFFFFB6C8);

  // ── 공통 — 테두리·코르크 보드 ───────────────────────────────────────────
  /// CBrown — 손그림 테두리 · RoomStatus ENDED
  static const Color CBrown = Color(0xFFD4B896);

  // ── 배경 위계 ───────────────────────────────────────────────────────────
  /// CIvory — 카드·TextField fill (배경 위의 배경)
  static const Color CIvory = Color(0xFFF2EDE6);

  /// CBackground — Scaffold 기본 (doc: 메인·방 페이지)
  static const Color CBackground = Color(0xFFFDF5DC);

  // ── 텍스트 (ErrorResponse.message, RoomSummary.name 등) ───────────────
  static const Color CTextPrimary = Color(0xFF2E231C);
  static const Color CTextSecondary = Color(0xFF5A4A3E);
  static const Color CTextTertiary = Color(0xFF7D6E62);
  static const Color CTextDisabled = Color(0xFFA89888);

  // ═══════════════════════════════════════════════════════════════════════
  // API 시맨틱 색 (doc/api-docs.json enum → Color)
  // ═══════════════════════════════════════════════════════════════════════

  /// RoomSummary.status / RoomDetail.status 배경
  static Color roomStatusBackground(RoomStatus status) => switch (status) {
        RoomStatus.waiting => CYellow.withValues(alpha: 0.55),
        RoomStatus.inProgress => COrange.withValues(alpha: 0.5),
        RoomStatus.ended => CBrown.withValues(alpha: 0.4),
      };

  /// RoomStatus 뱃지 글자색
  static Color roomStatusForeground(RoomStatus status) => switch (status) {
        RoomStatus.waiting => CTextPrimary,
        RoomStatus.inProgress => CTextPrimary,
        RoomStatus.ended => CTextSecondary,
      };

  /// MyReport.status 배경 (PENDING 폴링 / READY 결과)
  static Color reportStatusBackground(ReportStatus status) => switch (status) {
        ReportStatus.pending => COrange.withValues(alpha: 0.45),
        ReportStatus.ready => CPurple.withValues(alpha: 0.5),
      };

  static Color reportStatusForeground(ReportStatus status) => CTextPrimary;

  /// Note.direction 구분 (쪽지함 SENT / RECEIVED)
  static Color noteDirectionAccent(NoteDirection direction) =>
      switch (direction) {
        NoteDirection.sent => CPink.withValues(alpha: 0.65),
        NoteDirection.received => CSkyBlue.withValues(alpha: 0.65),
      };

  /// Mission.isCompleted
  static Color missionAccent({required bool isCompleted}) =>
      isCompleted ? CGreen : CYellow.withValues(alpha: 0.6);

  /// TodayQuestion.manitoAnswer.visibleToMe == false 블러 영역
  static Color answerBlurOverlay() => CBlue.withValues(alpha: 0.35);

  /// ErrorResponse — 스낵바·다이얼로그 에러 강조
  static const Color error = CRed;

  /// Note.isRead == false 받은 쪽지 강조
  static Color unreadNoteAccent() => CRed.withValues(alpha: 0.25);
}
