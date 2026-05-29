/// Flutter Web: HTTP ingest 비활성 — 브라우저 콘솔의 `[agent-debug]`만 사용.
///
/// 배포/원격 환경에서 `127.0.0.1:7477` POST는 500·CORS 노이즈만 유발합니다.
void postDebugLog(String line) {}
