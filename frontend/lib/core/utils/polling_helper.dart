import 'dart:async';

import '../network/api_enums.dart';

/// GET /rooms/{roomId}/results/my-report — [ReportStatus.pending] 폴링 스켈레톤.
///
/// 사용 예 (ResultRepository 구현 후):
/// ```dart
/// await PollingHelper.pollUntilReady(
///   fetchStatus: () => resultRepo.fetchMyReportStatus(roomId),
///   interval: const Duration(seconds: 3),
///   maxAttempts: 20,
///   onPending: (attempt) => AppLogger.d('report polling', attempt),
/// );
/// ```
class PollingHelper {
  PollingHelper._();

  /// [fetchStatus]가 [ReportStatus.ready]를 반환할 때까지 [interval]마다 반복.
  ///
  /// TODO: ResultRepository에서 실제 API 호출 연결
  /// TODO: 202 응답의 estimatedSeconds를 interval에 반영
  static Future<ReportStatus> pollUntilReady({
    required Future<ReportStatus> Function() fetchStatus,
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 20,
    void Function(int attempt)? onPending,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final status = await fetchStatus();

      if (status == ReportStatus.ready) {
        return status;
      }

      onPending?.call(attempt);

      if (attempt < maxAttempts) {
        await Future<void>.delayed(interval);
      }
    }

    return ReportStatus.pending;
  }

  /// Stream 기반 폴링 (Provider/Riverpod 구독용 스켈레톤)
  ///
  /// TODO: 구독 해제 시 [subscription.cancel()] 호출 필수
  static Stream<ReportStatus> pollAsStream({
    required Future<ReportStatus> Function() fetchStatus,
    Duration interval = const Duration(seconds: 3),
  }) async* {
    while (true) {
      yield await fetchStatus();
      await Future<void>.delayed(interval);
    }
  }
}
