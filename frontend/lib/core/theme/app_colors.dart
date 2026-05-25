
import 'package:flutter/material.dart';

class AppColors {
  // 생성자를 private으로 만들어 인스턴스화(new AppColors())를 방지합니다.
  AppColors._();

  // 🔴 토마토 레드: 메인 포인트 컬러 (로그인, 핵심 CTA 버튼)
  static const Color CRed = Color(0xFFFF7F7A);
  
  // 🟠 살구 오렌지: 진행 상태 (진행 중 뱃지, 미션 체크 애니메이션)
  static const Color COrange = Color(0xFFFFB347);
  
  // 🌼 버터 옐로: 강조 카드 (오늘의 질문 카드 배경, 스플래시 액센트)
  static const Color CYellow = Color(0xFFFFD966);
  
  // 🌿 민트 그린: 완료 / 성공 (미션 완료 체크, 성공 토스트)
  static const Color CGreen = Color(0xFFA8E6B0);
  
  // 🧊 스카이 민트: 쪽지 / 네비 (코르크 보드 핀, 네비 활성 아이콘)
  static const Color CSkyBlue = Color(0xFF7DD9D4);
  
  // 💙 라벤더 블루: 참여자 / 코드 (아바타 배경, 블러 처리 힌트 배경)
  static const Color CBlue = Color(0xFF9BB8F5);
  
  // 🫧 라일락 퍼플: 리포트 / 결과 (결과 유형 카드 배경, 마니또 공개 포인트)
  static const Color CPurple = Color(0xFFC8A9E8);
  
  // 🌸 페탈 핑크: 마니띠 / 쪽지 (나의 마니띠 카드, 쪽지 보내기 종이 배경)
  static const Color CPink = Color(0xFFFFB6C8);
  
  // 🍂 웜 샌드: 코르크 / 배경 (코르크 게시판 배경, 테두리)
  static const Color CBrown = Color(0xFFD4B896);
  
  // 🤍 크림 아이보리: 배경 베이스 (페이지 기본 배경, 오프화이트)
  static const Color CIvory = Color(0xFFF2EDE6);

  // ✨ 상단 텍스트에 포함되어 있던 웜 크림 액센트 색상
  static const Color CBackground = Color(0xFFFDF5DC);

  // 📝 텍스트 — Colors.black 대신 따뜻한 톤의 고대비 다크 톤
  // CIvory(#F2EDE6) 등 밝은 배경에서 WCAG AA 대비 확보
  static const Color CTextPrimary = Color(0xFF2E231C); // 제목·본문 기본 (딥 웜 브라운)
  static const Color CTextSecondary = Color(0xFF5A4A3E); // 부제·보조 설명
  static const Color CTextTertiary = Color(0xFF7D6E62); // 캡션·힌트·플레이스홀더
  static const Color CTextDisabled = Color(0xFFA89888); // 비활성·비어 있음 표시
}