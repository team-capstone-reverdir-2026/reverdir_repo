
# 🍅 또마니또 (To-Manito)
> 
> 익명 매칭부터 실시간 소통, AI 기반 활동 분석까지 완벽한 마니또 경험을 제공하는 소셜 플랫폼
<br>

![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![Firebase Cloud Messaging](https://img.shields.io/badge/FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Kakao Link](https://img.shields.io/badge/Kakao_Link-FFCD00?style=for-the-badge&logo=kakao&logoColor=black)
![OpenAI API](https://img.shields.io/badge/OpenAI_API-412991?style=for-the-badge&logo=openai&logoColor=white)

<br>

## 📌 1. Project Overview

### 🎯 프로젝트 목적
- 기존 오프라인 마니또 게임의 불편함 해결 (수기 매칭, 누락, 익명성 보장 어려움)
- 온라인 기반 자동 랜덤 매칭 시스템 제공
- 게임 진행 (미션 → 인증 → 결과 공개) 전 과정 디지털화

### 💡 핵심 문제 정의
- 참가자 수 증가 시 수작업 매칭의 비효율성
- 익명성 유지의 어려움
- 미션 수행 관리 부재

### 🧩 해결 전략
- 서버 기반 자동 매칭 알고리즘
- 익명 ID 기반 사용자 구조
- 상태 기반 게임 플로우 설계 (JOIN → MATCH → PLAY → RESULT)

---

## 👥 2. Team & Roles

| 이름 | 역할 |
|------|------|
| A | Frontend (UI/UX, React) |
| B | Backend (API, DB 설계) |
| C | Game Logic / Matching Algorithm |
| D | DevOps / Deployment |

---

## 🏗 3. System Architecture

### 📌 Architecture Overview

Client (React)
↓
REST API Layer (Node.js / Express or Spring Boot)
↓
Service Layer (Game Logic / Matching Engine)
↓
Database (MySQL / PostgreSQL)


### 📦 Component Separation

**Frontend**
- UI 상태 관리
- API 요청 처리
- 게임 진행 화면 렌더링

**Backend**
- 인증 (JWT)
- 게임 세션 관리
- 매칭 알고리즘 실행
- 미션 생성 및 상태 업데이트

**Database**
- User / Game / Match / Mission 테이블 관리
- 관계형 구조 기반 데이터 무결성 유지

---

## 🛠 4. Tech Stack

### Frontend
- Flutter
- Dart

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

---

## 🚀 5. Key Features

### 🎯 1. 익명 마니또 매칭 시스템
- 참가자 기반 1:1 순환 매칭
- 자기 자신 매칭 방지
- 서버 단일 트랜잭션 처리

### 💌 2. 미션 시스템
- 하루 단위 자동 미션 생성
- 사용자 수행 여부 체크
- 게임 진행 상태 기반 미션 활성화

### 🔔 3. 익명 메시지 / 힌트 시스템
- Sender ID 익명화 처리
- 힌트 기반 간접 커뮤니케이션

### 📊 4. 결과 공개 시스템
- 게임 종료 시 전체 매칭 결과 공개
- 참여자 검증 가능 구조

---

## 🧠 Core Algorithm (Matching Engine)

### 📌 문제 정의
- N명의 참가자를 중복 없이 1:1 매칭
- 자기 자신 매칭 금지
- 완전한 순환 구조 유지

---

## 🔌 API Documentation

### User API
- POST /api/user/signup : 회원가입
- POST /api/user/login : 로그인

### Game API
- POST /api/game/join : 게임 참여
- POST /api/game/match : 매칭 실행

### Mission API
- GET /api/mission/today
- POST /api/mission/complete

---

## ⚠️ Environment Variables

프로젝트 실행을 위해 아래 환경 변수 설정이 필요합니다.

```
DB_URL=***
DB_USER=***
DB_PASSWORD=***
JWT_SECRET=***
GEMINI_API_KEY=***
```

---

## ⚙️ How to Run

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

---

## 🚀 Deployment

- Frontend: Vercel
- Backend: Render
- Database: Render PostgreSQL

---

## 🔐 Security Considerations

- JWT 기반 인증으로 사용자 세션 관리
- 비밀번호는 bcrypt를 이용해 단방향 해싱 처리
- 민감 정보는 환경 변수로 (.env) 분리하여 관리

---

## 🚀 Future Improvements

- AI 기반 방 맞춤 미션 추천
- 실시간 채팅 시스템 (WebSocket)
- 실시간 마니띠 랭킹 시스템
- 현재 의심 중인 상대 설정
- 개인화된 AI 결과 리포트 (방사형 그래프 도입 외)











## 📌 Overview
또마니또(To-Manito)는 오프라인에서 수작업으로 진행되던 전통적인 '마니또(Secret Santa)' 이벤트를 디지털화하고, AI 기반의 콘텐츠와 게임화(Gamification) 요소를 결합해 확장한 모바일 서비스입니다.

단순한 익명 매칭과 결과 발표를 넘어, 그룹의 성격에 맞춘 AI 맞춤형 미션, 실시간 채팅, 활동량에 따른 실시간 랭킹 보드, 그리고 활동 종료 후 제공되는 **AI 마니또 캐릭터 리포트**를 통해 참여자들에게 지속적인 동기를 부여하고 새로운 상호작용 경험을 제공합니다.

<br>

## 🎯 Target & Problem Definition

### Target Audience
* **사내 소규모 조직 및 팀:** 어색한 분위기를 깨고 자연스러운 유대감을 형성하고자 하는 직장인 그룹
* **대학교 학과/동아리:** 다수의 인원이 참여하여 단합과 재미를 추구하는 대학생 커뮤니티
* **온라인 커뮤니티 (게임 길드 등):** 오프라인 만남이나 개인정보 노출 없이 익명 이벤트를 즐기고 싶은 비대면 그룹

### Pain Points
* **진행의 비효율성:** 종이 뽑기, 수동 관리 등 오프라인 방식의 한계와 빈번한 정체 탄로
* **빠른 흥미 이탈:** 매칭 이후 '무엇을 해야 할지' 몰라 발생하는 소통 부재와 낮은 참여율
* **단방향적 관계:** 마니또-마니띠의 1:1 관계에만 치중되어 그룹 전체의 상호작용 부족
* **휘발되는 경험:** 활동 내역이 기록되지 않아 이벤트 종료 시점의 만족도 하락

<br>

## ✨ Key Features

* **🎲 방 생성 및 익명 자동 매칭**
  * 초대 코드 기반의 독립적인 룸(Room) 생성
  * 서버 사이드 무작위 익명 매칭
* **🖥 AI 맞춤형 환경 구성 (Contextual Generator)**
  * 방 생성 시 입력된 메타데이터(모임 성격)를 AI가 분석
  * 해당 그룹 특성에 최적화된 추천 미션 템플릿 자동 생성
* **📋 게임화된 상호작용 (Gamified Interaction)**
  * 단방향/역방향 익명 비밀 쪽지 및 선물 기록 시스템
  * 힌트 열람 및 실시간 마니또로 의심되는 상대 설정 기능
  * 미션 달성도, 쪽지, 선물 등 활동량 기반의 실시간 랭킹 보드
* **🤖 AI 기반 활동 리포트 (Persona Analysis)**
  * 마니또 종료 시, 유저의 활동 데이터를 AI가 종합 분석
  * 개인별 '마니또 캐릭터 유형' 명명 및 방사형 그래프가 포함된 결과 리포트 발급

<br>

## 📚 Documentation

* 📌 [Team Ground Rule](https://github.com/team-capstone-reverdir-2026/reverdir_repo/blob/main/Team_Ground_Rule.md)
* 📌 [Team Notion](https://www.notion.so/2026-capstone-fd7d4a4683e182fd9cea81cca11a4b88)
* 📌 [Project Plan](https://www.notion.so/2026-capstone-fd7d4a4683e182fd9cea81cca11a4b88)

<br>

## 🛠 Tech Stack

### Backend
* Java 17
* Spring Boot 4.0.6

### Database
* MySQL 8.0

### Frontend
* Flutter 3.41.5
* Dart 3.11.3

### External Services
* OpenAI API
* kakao Link API
* Firebase Cloud Messaging (FCM)

<br>

## Project Structure

<br>

## How to Run

<br>
