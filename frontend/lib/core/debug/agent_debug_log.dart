import 'dart:convert';
import 'dart:io' if (dart.library.html) 'agent_debug_log_stub.dart' as io;

import 'package:flutter/foundation.dart';

/// Debug-mode NDJSON logger (session 45384d).
class AgentDebugLog {
  AgentDebugLog._();

  static const _sessionId = '45384d';
  static const _logPath =
      r'c:\BackGround\Univ\Reverdir\reverdir_repo\debug-45384d.log';

  static void log({
    required String location,
    required String message,
    required String hypothesisId,
    Map<String, dynamic>? data,
    String runId = 'pre-fix',
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final payload = <String, dynamic>{
      'id': 'log_${ts}_45384d',
      'sessionId': _sessionId,
      'timestamp': ts,
      'location': location,
      'message': message,
      'hypothesisId': hypothesisId,
      'data': data ?? <String, dynamic>{},
      'runId': runId,
    };
    final line = jsonEncode(payload);
    debugPrint('[agent-debug] $line');

    // #region agent log transport
    // Web: debugPrint만 (ingest POST는 500/CORS로 콘솔 오염). Desktop: NDJSON 파일.
    if (!kIsWeb) {
      try {
        io.File(_logPath).writeAsStringSync(
          '$line\n',
          mode: io.FileMode.append,
        );
      } catch (_) {}
    }
    // #endregion
  }
}
