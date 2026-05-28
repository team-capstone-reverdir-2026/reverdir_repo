import 'dart:convert';
import 'dart:io' if (dart.library.html) 'agent_debug_log_stub.dart' as io;

import 'package:flutter/foundation.dart';

import 'agent_debug_log_transport.dart'
    if (dart.library.html) 'agent_debug_log_transport_web.dart' as transport;

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
    final payload = <String, dynamic>{
      'sessionId': _sessionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'hypothesisId': hypothesisId,
      'data': data ?? <String, dynamic>{},
      'runId': runId,
    };
    final line = jsonEncode(payload);
    debugPrint('[agent-debug] $line');

    // #region agent log transport
    if (kIsWeb) {
      transport.postDebugLog(line);
    } else {
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
