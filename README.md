
# 🍅 또마니또 (To-Manito)
> 
> 익명 기반 상호작용으로 사람들 사이의 관계 형성과 친밀감 경험을 설계하는 소셜 게임 플랫폼
<br>


![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=jsonwebtokens)
![Gemini API](https://img.shields.io/badge/Gemini_API-412991?style=for-the-badge&logo=google&logoColor=white)

<br>

🚀 **서비스 체험하기**  
👉 MVP 데모: https://tomanito.vercel.app/

<br>

## 📌 1. Project Overview

> 사람들 사이에 자연스럽게 알아가고, 이어지고, 더 가까워질 계기를 만들어주는 익명 기반 관계 경험 플랫폼입니다.
> 사용자 간 자연스러운 관계 형성과 지속적인 상호작용을 목표로 합니다.

<br>

### 🎯 프로젝트 목적
사람들은 새로운 관계를 맺고 싶어하지만,
그 관계를 자연스럽게 시작하고 이어갈 수 있는 구조는 많지 않습니다.

특히 기존 마니또나 친목 기반 서비스는
처음에는 흥미를 느끼지만 시간이 지나면서 참여 동기가 약해지고,
결국 관계 형성 경험이 충분히 이어지지 못하는 문제가 있습니다.

이 프로젝트는 관계가 자연스럽게 시작되고, 이어지고, 깊어지는 경험을 만드는 것을 목표로 합니다.

### 💡 핵심 문제 정의
기존 마니또/친목 기반 서비스는 다음과 같은 한계를 가집니다.

- 이벤트성으로 끝나 지속적인 관계 경험으로 이어지지 않음
- 참여를 유지할 수 있는 동기 구조 부족
- 사람 간 자연스러운 대화를 유도하는 장치 부족
- 시간이 지나면서 자연스럽게 참여와 관심이 감소

결과적으로 처음에는 재미있지만, 점점 흐지부지되는 구조가 반복되기 쉽습니다.

### 🧩 해결 전략
이 문제를 해결하기 위해,
단발성 게임이 아니라 사용자 간 관계가 자연스럽게 쌓이고 유지되는 구조를 설계했습니다.

이를 위해 다음과 같은 기능들을 제공합니다.

- 익명 마니또 매칭 → 부담 없이 새로운 관계를 시작할 수 있는 구조
- 1일 1질문 시스템 → 서로의 생각과 취향을 자연스럽게 알아가는 지속적인 접점
- 익명 쪽지 기능 → 직접적 부담 없이 관심과 감정을 가볍게 전달할 수 있는 상호작용
- AI 행동 분석 리포트 → 게임 내 상호작용을 기반으로 관계 경험을 되돌아볼 수 있는 피드백 제공

<br>

---

## 👥 2. Team & Roles

| 이름 | 역할 |
|------|------|
| 이은효 | Frontend |
| Lyu Dongying | Frontend |
| 전채연 | Backend |

<br>
 
---

## 🏗 3. System Architecture

### 📌 Architecture Overview

```
Client (Flutter)
↓
REST API Layer (Spring Boot)
↓
Service Layer (Game Logic / Matching Engine) → Gemini 3.1 Flash
↓
Database (Render PostgreSQL)
```

### 📦 Component Separation

**Frontend**
- UI 상태 관리
- API 요청 처리
- 게임 화면 렌더링

**Backend**
- 인증 (JWT)
- 게임 세션 관리
- 매칭 알고리즘 실행
- 미션 생성 및 상태 업데이트

**Database**
- 테이블 관리
- 관계형 구조 기반 데이터 무결성 유지
 
<br>
 
---

## 🔄 4. Service Flow
이 프로젝트는 다음 흐름으로 구성됩니다.
```
사용자 로그인
    ↓
방 생성
    ↓
참여자 입장
    ↓
게임 시작
    ↓
마니또 자동 매칭
    ↓
질문 / 미션 / 쪽지 수행
    ↓
게임 종료
    ↓
결과 공개
    ↓
AI 리포트 생성
```
 
<br>
 
---

## 🛠 5. Tech Stack

### Frontend
- Flutter 3.41.5
- Dart 3.11.3

### Backend
- Spring Boot 4.0.6
- Java 17
- REST API
- JWT Authentication

### Database
- Render PostgreSQL

### Deployment
- Vercel
- Render
 
<br>
 
---
## 📡 6. External Services & APIs
- 🤖 Gemini 3.1 Flash  
  → 게임 내 행동 데이터를 기반으로 AI 결과 리포트 생성

- 💬 Kakao API (planned)  
  → 참여 링크 공유 및 결과 리포트 공유 기능 확장 예정

- 🔔 Firebase Cloud Messaging (planned)  
  → 게임 진행 및 상호작용 알림 기능 확장 예정
 
<br>
 
---

## 🚀 7. Key Features

### 🎯 1. 익명 마니또 매칭 시스템
- 참가자 기반 1:1 순환 매칭
- 자기 자신 매칭 방지
- 서버 단일 트랜잭션 처리
- 게임 시작 시 자동 매칭 생성

### 🎲 2. 미션 시스템
- 사용자 정의 미션 생성/수정/삭제
- 랜덤 미션 추천 기능 제공
- 개인별 미션 관리

### 💌 3. 익명 쪽지 시스템
- 정체를 숨긴 상태로 메시지 전송
- 보낸 쪽지함 / 받은 쪽지함 제공
- 읽음 여부 관리
- 게임 종료 전까지 발신자 정보 비공개

### 🔔 4. 오늘의 질문(힌트) 시스템
- 방 단위로 하루 1개의 질문 자동 제공
- DB에 저장된 질문 풀에서 랜덤 추출
- 같은 방의 모든 참여자에게 동일한 질문 제공
- 방마다 서로 다른 질문 세트 운영
- 답변 히스토리를 통한 간접 힌트 제공

### 🤝 5. 참여자 관리 시스템
- 방 입장 시 참여자 등록
- 참여자 목록 조회
- 방 단위 멤버 관리
- 게임 참여 상태 추적

### 📊 6. 결과 공개 시스템
- 게임 종료 시 전체 매칭 결과 공개
- 마니또/마니띠 관계 확인

### 🤖 7. Gemini 기반 행동 분석 리포트
- Gemini 3.1 Flash 기반 개인별 결과 리포트 생성
- 게임 중 생성된 활동 로그 수집 및 분석
- 쪽지 전송 횟수, 평균 메시지 길이, 주요 활동 시간대 등을 기반으로 사용자 참여 패턴 도출
- 개인별 참여 패턴 리포트 생성
- 향후 질문 응답, 미션 수행 내역 등 추가 데이터 기반 분석 확장 예정
 
<br>
 
---

## 🖼 8. Screenshots

### 🍅 또마니또 서비스 전체 흐름

아래 이미지는 또마니또의 주요 사용자 경험을 순서대로 배치한 통합 스크린샷입니다.

좌측부터 순서대로

1. 마니또 게임 진행 화면
2. 익명 쪽지함
3. 오늘의 질문(힌트) 히스토리
4.  Gemini 기반 행동 분석 리포트

과정을 보여줍니다.

사용자는 게임 기간 동안 익명 상태로 상호작용하며, 게임 종료 후 자신의 마니또 관계와 AI 분석 결과를 확인할 수 있습니다.

<img width="1607" height="796" alt="데모 주요 화면 스크린샷" src="https://github.com/user-attachments/assets/f4739e7d-6c60-43d6-8641-d53749b1bc67" />

  
<br>  
<br>
 
---

## 9. Database Design

### Entity Relationship Diagram (ERD)
<img width="700" alt="image" src="https://github.com/user-attachments/assets/e16b20e4-b6cd-473e-aee6-f96bc3ce0e9c" />


### Core Entities
```
- User: 사용자 정보
- Room: 게임이 진행되는 공간
- Participant: Room 내 사용자 참여 정보
- QuestionTemplate: 질문 템플릿 저장
- Question: 특정 게임에서 실제 출제된 질문
- Answer: 특정 게임에서 실제 출제된 질문에 대한 사용자별 답 
- MissionTemplate: 미션 템플릿 저장
- Mission: 특정 참가자에게 할당된 미션
- Note: 익명 쪽지
- ParticipantReport: Gemini 분석 결과
```
 
<br>
 
---

### 📂 10. Project Structure

```
reverdir/

├── frontend/
│   ├── auth/              # 로그인 / 회원가입
│   ├── main/              # 홈 화면
│   ├── room/              # 방 생성 / 참여
│   ├── manitto_game/      # 게임 진행
│   ├── mission/           # 미션 시스템
│   ├── hint/              # 힌트 시스템
│   ├── letter/            # 익명 쪽지
│   ├── game_result/       # AI 결과 리포트
│   └── core/              # 공통 위젯 / 상태관리 / 유틸
│
├── backend/
│   ├── auth/              # JWT 인증 / 로그인
│   ├── user/              # 사용자 관리
│   ├── room/              # 방 / 참여자 관리
│   ├── game/              # 마니또 매칭 / 게임 lifecycle
│   ├── mission/           # 미션 CRUD / 랜덤 미션
│   ├── question/          # 오늘의 질문 시스템
│   ├── note/              # 익명 쪽지 시스템
│   ├── result/            # Gemini 기반 AI 리포트
│   └── global/            # 공통 응답 / 예외 / 설정
│
├── docs/                  # API 명세 / 설계 문서
└── README.md
```
 
<br>
 
---

## ⚠️ 11. Environment Variables

프로젝트 실행을 위해 아래 환경 변수 설정이 필요합니다.

```
DB_URL=***
DB_USER=***
DB_PASSWORD=***
JWT_SECRET=***
GEMINI_API_KEY=***
```
 
<br>
 
---

## ⚙️ 12. How to Run

```
### 1️⃣ Clone Repository
git clone https://github.com/team-capstone-reverdir-2026/reverdir_repo.git

### 2️⃣ Frontend
cd frontend
flutter pub get
flutter run -d chrome

### 3️⃣ Backend
cd backend
./gradlew build
./gradlew bootRun
```
 
<br>
 
---

## 🚀 13. Deployment

- Frontend: Vercel
- Backend: Render
- Database: Render PostgreSQL
 
<br>
 
---

## 🔐 14. Security Considerations

- JWT 기반 인증으로 사용자 세션 관리
- 비밀번호는 bcrypt를 이용해 단방향 해싱 처리
- 민감 정보는 환경 변수로 (.env) 분리하여 관리
 
<br>
 
---

## 🚀 15. Future Improvements

- AI 기반 방 맞춤 미션 추천
- 실시간 채팅 시스템 (WebSocket)
- 실시간 마니띠 랭킹 시스템
- 현재 의심 중인 상대 설정
- 더욱 개인화된 AI 결과 리포트 (방사형 그래프 도입 외)
 
<br>
 
---

## 📚 16. Documentation

* 📌 [Team Ground Rule](https://github.com/team-capstone-reverdir-2026/reverdir_repo/blob/main/Team_Ground_Rule.md)
* 📌 [Team Notion](https://www.notion.so/2026-capstone-fd7d4a4683e182fd9cea81cca11a4b88)

---

