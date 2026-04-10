
# 🍅 또마니또 (Tto-Manito)
> 
> 익명 매칭부터 실시간 소통, AI 기반 활동 분석까지 완벽한 마니또 경험을 제공하는 소셜 플랫폼
<br>

![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Firebase Cloud Messaging](https://img.shields.io/badge/FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Kakao Link](https://img.shields.io/badge/Kakao_Link-FFCD00?style=for-the-badge&logo=kakao&logoColor=black)
![OpenAI API](https://img.shields.io/badge/OpenAI_API-412991?style=for-the-badge&logo=openai&logoColor=white)

<br>

## 🚀 Overview
또마니또(Tto-Manito)는 오프라인에서 수작업으로 진행되던 전통적인 '마니또(Secret Santa)' 이벤트를 디지털화하고, AI 기반의 콘텐츠와 게임화(Gamification) 요소를 결합해 확장한 모바일 서비스입니다.

단순한 익명 매칭과 결과 발표를 넘어, 그룹의 성격에 맞춘 **AI 맞춤형 미션/힌트 생성**, 실시간 채팅, 활동량에 따른 실시간 랭킹 보드, 그리고 활동 종료 후 제공되는 **AI 마니또 캐릭터 리포트**를 통해 참여자들에게 지속적인 동기를 부여하고 새로운 상호작용 경험을 제공합니다.

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
  * 해당 그룹 특성에 최적화된 추천 미션 및 힌트 템플릿 자동 생성
* **📋 게임화된 상호작용 (Gamified Interaction)**
  * 단방향/역방향 익명 비밀 쪽지 및 선물 기록 시스템
  * 힌트 열람 및 실시간 마니또로 의심되는 상대 설정 기능
  * 미션 달성도, 쪽지, 선물 등 활동량 기반의 실시간 랭킹 보드
* **🤖 AI 기반 활동 리포트 (Persona Analysis)**
  * 마니또 종료 시, 유저의 활동 데이터를 AI가 종합 분석
  * 개인별 '마니또 캐릭터 유형' 명명 및 방사형 그래프가 포함된 결과 리포트 발급
 
## 📚 Documentation

* 📌 [Team Ground Rule](https://github.com/team-capstone-reverdir-2026/reverdir_repo/blob/main/Team_Ground_Rule.md)
* 📌 [Team Notion](https://www.notion.so/2026-capstone-fd7d4a4683e182fd9cea81cca11a4b88)

## 🛠 Tech Stack

### Backend
* **Language & Framework:** Java 17, Spring Boot
* **Database:** PostgreSQL (RDBMS)
* **API & External Services:** * OpenAI API (AI 마니또 페르소나 분석 및 텍스트 생성)
  * Firebase Cloud Messaging / FCM (실시간 푸시 알림)
  * Kakao Link API (카카오톡 초대 코드 공유)
* **Version Control:** Git & GitHub

### Frontend
* **Framework:** Flutter (Dart)

<br>

## 🚀 Getting Started

### Prerequisites
* JDK 17+
* Flutter SDK 3.x+
* PostgreSQL 14+
* Firebase 연동 파일 (`google-services.json`)
* Kakao API Key 및 OpenAI API Key

### Backend Installation
```bash
# 1. Repository Clone
$git clone [https://github.com/Reverdir/Tto-Manito.git$](https://github.com/Reverdir/Tto-Manito.git$) cd Tto-Manito/backend

# 2. application.yml 환경변수 설정
# (src/main/resources/application.yml 파일에 DB 접속 정보 및 각종 API Key 설정 필요)

# 3. Spring Boot 실행
$./gradlew build$ ./gradlew bootRun

<br>
