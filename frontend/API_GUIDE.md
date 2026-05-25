# 또마니또 Frontend API Guide

이 문서는 `doc/api-docs.json`을 기준으로 현재 Flutter 프론트엔드가 어떤 화면에서 어떤 API 응답을 기대하는지 정리한 가이드입니다. 현재 앱은 `MockGameService`로 동작하지만, 실제 백엔드 연결 시 아래 계약을 Repository/Service 구현으로 교체하면 됩니다.

## 공통 규칙

- Base URL은 `lib/core/network/api_endpoints.dart`의 `ApiEndpoints`를 기준으로 사용합니다.
- 인증이 필요한 API는 `Authorization: Bearer <accessToken>` 헤더를 사용합니다.
- 인증 예외 경로는 `/auth/register`, `/auth/login`, `/auth/refresh`입니다.
- 에러 응답은 공통적으로 `ErrorResponse` 형태를 사용합니다.
- 상태 enum은 서버 wire value를 그대로 내려줘야 합니다.
  - `RoomStatus`: `WAITING`, `IN_PROGRESS`, `ENDED`
  - `Note.direction`: `SENT`, `RECEIVED`
  - `MyReport.status`: `PENDING`, `READY`
- 날짜 형식은 명세를 따라야 합니다.
  - `date-time`: ISO 8601, 예: `2026-05-25T18:00:00+09:00`
  - `date`: `YYYY-MM-DD`

## 인증

### 회원가입

`POST /auth/register`

사용 시점: 회원가입 화면에서 계정 생성 시 호출합니다.

요청:

```json
{
  "username": "tomato",
  "password": "password",
  "displayName": "토마"
}
```

백엔드는 가입 성공 시 로그인과 동일하게 토큰을 내려주거나, 프론트가 즉시 로그인 API를 호출할 수 있도록 성공 응답을 명확히 제공해야 합니다. 중복 아이디는 `DUPLICATE_USERNAME` 에러 코드를 사용합니다.

### 로그인

`POST /auth/login`

사용 시점: 로그인 화면에서 호출합니다.

백엔드는 `accessToken`, `refreshToken`, 사용자 식별 정보(`userId`, `username` 등)를 내려줘야 합니다. 프론트는 토큰을 `SecureStorageService`에 저장하고 이후 API 요청에 사용합니다.

### 토큰 재발급

`POST /auth/refresh`

사용 시점: `AuthInterceptor`가 401을 받았을 때 refresh token으로 access token 재발급을 시도합니다.

백엔드는 새 `accessToken`과 필요 시 새 `refreshToken`을 내려줘야 합니다. 실패하면 프론트는 토큰을 삭제하고 로그인 화면으로 이동합니다.

## 방 목록과 방 상세

### 참여 중인 방 목록

`GET /rooms`

사용 시점: 홈 화면에서 참여 중인 방 목록을 보여줄 때 호출합니다.

응답은 `{ "rooms": RoomSummary[] }` 형태입니다. 각 방은 `id`, `name`, `status`, `participantCount`를 포함해야 합니다.

### 방 생성

`POST /rooms`

사용 시점: 방 만들기 화면에서 호출합니다.

요청은 `CreateRoomRequest`를 따릅니다. `name`, `endsAt`, `missionCount`는 필수이고, `description`은 선택값입니다. 성공 시 `roomId`, `inviteCode`, `name`, `description`, `endsAt`, `missionCount`를 내려줘야 합니다.

### 초대 코드 확인

`POST /rooms/join`

사용 시점: 초대 코드 입력 후 방 정보를 미리 보여줄 때 호출합니다.

요청은 `{ "inviteCode": "A3F9K2" }` 형태입니다. 성공 시 `RoomJoinPreview`를 내려줍니다. 잘못된 코드는 `INVALID_INVITE_CODE`, 이미 참여 중이면 `ALREADY_JOINED`를 사용합니다.

### 방 상세

`GET /rooms/{roomId}`

사용 시점: 방 메인 진입 시 가장 먼저 호출합니다.

응답은 `RoomDetail`입니다. 프론트는 `status`에 따라 시작 전, 진행 중, 종료 후 화면을 분기합니다.

- `WAITING`: `pre_start_view.dart`
- `IN_PROGRESS`: `in_progress_view.dart`
- `ENDED`: `finished_view.dart`

`RoomDetail`에는 `id`, `name`, `description`, `status`, `inviteCode`, `endsAt`, `missionCount`, `participantCount`, `daysRemaining`, `isHost`가 포함되어야 합니다.

## 참여자

`GET /rooms/{roomId}/participants`

사용 시점: 시작 전 화면의 참여자 목록과 진행 중 참여자 바텀시트에서 호출합니다.

응답은 `{ "participants": Participant[] }`입니다. 각 참여자는 `userId`, `displayName`, `missionCount`, `isHost`를 포함해야 합니다. 시작 전 화면은 `missionCount / RoomDetail.missionCount`로 준비 현황 스티커를 표시합니다.

## 미션

### 내 미션 목록

`GET /rooms/{roomId}/missions`

사용 시점: 시작 전 미션 CRUD 영역과 진행 중 오늘의 미션 체크리스트에서 호출합니다.

응답은 `{ "missions": Mission[], "maxCount": number }`입니다. `Mission`은 `id`, `content`, `isCompleted`, `createdAt`를 포함해야 합니다.

### 미션 추가

`POST /rooms/{roomId}/missions`

사용 시점: 시작 전 페이지에서 내가 작성한 미션을 추가할 때 호출합니다.

요청:

```json
{
  "content": "매일 아침 인사 먼저 하기"
}
```

`content`는 최대 200자입니다. 방의 `missionCount`를 초과하면 `MISSION_LIMIT_EXCEEDED`를 반환해야 합니다.

### 미션 수정/체크

`PATCH /rooms/{roomId}/missions/{missionId}`

사용 시점: 시작 전 미션 문구 수정 또는 진행 중 미션 체크박스 토글 시 호출합니다.

요청은 상황에 따라 `content`, `isCompleted` 중 하나 또는 둘 다 포함할 수 있습니다.

### 미션 삭제

`DELETE /rooms/{roomId}/missions/{missionId}`

사용 시점: 시작 전 페이지에서 내가 작성한 미션을 삭제할 때 호출합니다.

성공 시 204를 반환합니다.

### 랜덤 미션 추천

`GET /missions/random`

사용 시점: 시작 전 페이지의 새로고침 버튼을 누를 때 호출합니다.

현재 프론트는 Mock 데이터셋에서 추천 미션을 입력창에 채웁니다. 실제 API 연결 시 현재 입력된 미션과 중복되지 않도록 `excludeIds` 쿼리를 전달할 수 있습니다. 응답은 `{ "content": "마니띠가 좋아하는 음료수 몰래 사다주기" }` 형태입니다.

## 게임 상태

### 게임 시작

`POST /rooms/{roomId}/game/start`

사용 시점: 시작 전 페이지에서 방장이 하단 고정 버튼 `마니또 시작하기`를 누를 때 호출합니다.

백엔드는 마니또 관계를 배정하고 `{ "status": "IN_PROGRESS", "startedAt": "<date-time>" }`를 내려줘야 합니다. 참여자가 부족하면 `NOT_ENOUGH_PARTICIPANTS`, 방장이 아니면 `NOT_HOST`를 반환합니다.

### 게임 강제 종료

`POST /rooms/{roomId}/game/end`

사용 시점: 데모 관리 화면에서 `게임 종료하기`를 누를 때 호출합니다.

백엔드는 `{ "status": "ENDED", "endedAt": "<date-time>" }`를 내려줘야 합니다.

### 내 마니띠 조회

`GET /rooms/{roomId}/my-manitti`

사용 시점: 진행 중 메인 화면의 “내가 챙겨줄 마니띠” 카드에서 호출합니다.

응답은 `{ "displayName": "이영희" }` 형태입니다. 게임 시작 전에는 403을 반환할 수 있습니다.

## 오늘의 질문과 힌트

### 오늘의 질문 조회

`GET /rooms/{roomId}/questions/today`

사용 시점: 진행 중 메인 화면의 오늘의 질문 카드에서 호출합니다.

응답은 `TodayQuestion`입니다. `myAnswer.answered`, `myAnswer.content`, `manitoAnswer.answered`, `manitoAnswer.visibleToMe`, `manitoAnswer.content`를 포함해야 합니다.

프론트 규칙:

- `myAnswer.answered == false`이면 내 답변 입력창을 보여줍니다.
- 내가 답변하지 않은 상태에서 마니또가 답변했더라도 `visibleToMe == false`이면 마니또 답변 영역은 블러 처리합니다.
- 내가 답변을 제출하면 프론트는 즉시 내 답변 완료 상태로 전환하고, 실제 API 연결 시 응답을 기준으로 다시 갱신합니다.

### 오늘의 질문 답변 등록/수정

`POST /rooms/{roomId}/questions/today/answer`

사용 시점: 오늘의 질문 입력창에서 제출 버튼 또는 Enter/Submit 키 입력 시 호출합니다.

요청:

```json
{
  "content": "겨울이요. 눈이 좋아요."
}
```

성공 시 `Answer`를 반환합니다. 이후 프론트는 `GET /rooms/{roomId}/questions/today`를 다시 호출하거나, 서버가 내려준 `Answer`와 기존 질문 상태를 조합해 `myAnswered` 상태를 갱신합니다.

### 질문/답변 히스토리

`GET /rooms/{roomId}/questions/history`

사용 시점: 힌트 답변 모음 화면에서 호출합니다.

응답은 `{ "history": QuestionHistoryItem[] }`입니다. 최신 날짜순 내림차순으로 내려주는 것이 좋습니다. 내가 답변하지 않은 날은 `isBlurred: true`이고 `manitoAnswer`는 `null`이거나 숨김 처리 가능한 값이어야 합니다.

## 쪽지

### 쪽지 보내기

`POST /rooms/{roomId}/notes`

사용 시점: 진행 중 하단 바의 `쪽지 쓰기` 화면에서 전송 버튼을 누를 때 호출합니다.

요청:

```json
{
  "content": "오늘도 수고했어요! 슬쩍 간식 두고 갔어요 :)"
}
```

`content`는 최대 1000자입니다. 성공 시 `Note`를 반환합니다. 게임 종료 후에는 `GAME_ENDED`를 반환해야 합니다.

### 보낸 쪽지함

`GET /rooms/{roomId}/notes/sent`

사용 시점: 쪽지함의 `보낸 쪽지함` 탭에서 호출합니다.

날짜 필터가 있으면 `from=YYYY-MM-DD`, `to=YYYY-MM-DD` 쿼리를 전달합니다. 응답은 `{ "notes": Note[] }`이며 최신순 내림차순이어야 합니다.

### 받은 쪽지함

`GET /rooms/{roomId}/notes/received`

사용 시점: 쪽지함 진입 시 기본 탭인 `받은 쪽지함`에서 호출합니다.

날짜 필터 규칙은 보낸 쪽지함과 동일합니다. `isRead` 값에 따라 프론트는 비밀 쪽지를 접힌 종이 또는 펼쳐진 종이 형태로 보여줍니다.

### 쪽지 읽음 처리

`PATCH /rooms/{roomId}/notes/{noteId}/read`

사용 시점: 받은 쪽지를 클릭해 상세 팝업을 열 때 호출합니다.

성공 시 읽음 처리된 `Note`를 반환합니다. 프론트는 같은 배경색을 유지하면서 아이콘/문구만 읽음 상태에 맞춰 변경합니다.

## 결과 리포트

### 마니또 공개 결과

`GET /rooms/{roomId}/results/manitto-reveal`

사용 시점: 종료 후 화면에서 `결과 보기`를 누른 뒤 리포트 1페이지에서 호출합니다.

응답은 `ManittoRevealResult`입니다.

- `myManitto`: 나를 챙겨준 마니또의 `userId`, `displayName`
- `chain`: 전체 마니또 관계 순환 고리. 각 항목은 `manitto`, `manitti`를 포함합니다.

게임이 종료되지 않았으면 `GAME_NOT_ENDED`를 반환해야 합니다.

### 내 결과 분석 리포트

`GET /rooms/{roomId}/results/my-report`

사용 시점: 리포트 2페이지에서 호출합니다.

응답은 `MyReport`입니다. `status`가 `READY`이면 `typeName`, `typeImageUrl`, `storyText`를 제공해야 합니다. `PENDING`이면 프론트는 폴링을 이어가고 로딩 상태를 표시합니다. 202 응답으로 생성 중 상태를 내려줄 수도 있습니다.

## 실제 API 연결 시 프론트 전환 지점

- `MockGameService`는 현재 로컬 체험용 상태 저장소입니다.
- 실제 연결 시 기능별 Repository를 만들고 `ApiClient`와 `ApiEndpoints`를 사용해 HTTP 요청으로 교체합니다.
- UI 위젯은 가능한 한 `RoomDetail`, `Participant`, `Mission`, `TodayQuestion`, `QuestionHistoryItem`, `Note`, `ManittoRevealResult`, `MyReport`에 대응하는 ViewData만 소비하도록 유지합니다.
- 서버 응답 enum 문자열은 반드시 `api_enums.dart`의 `tryParse`가 처리하는 wire value와 일치해야 합니다.
- 에러 응답의 `code`와 `message`는 `ErrorHandler`가 사용자 메시지로 변환합니다.
