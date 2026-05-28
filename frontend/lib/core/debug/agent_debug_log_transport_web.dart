import 'dart:html';

const _endpoint =
    'http://127.0.0.1:7477/ingest/01ad35b3-6f2b-4a36-ad6d-c65293bfea20';

/// Flutter Web: POST NDJSON line to local debug ingest.
void postDebugLog(String line) {
  HttpRequest.request(
    _endpoint,
    method: 'POST',
    requestHeaders: {
      'Content-Type': 'application/json',
      'X-Debug-Session-Id': '45384d',
    },
    sendData: line,
  ).catchError((_) => null);
}
