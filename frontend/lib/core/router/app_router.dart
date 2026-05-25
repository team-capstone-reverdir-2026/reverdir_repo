import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/manitto_game/presentation/game_main_screen.dart';
import '../storage/secure_storage_service.dart';
import 'app_routes.dart';

/// go_router 기반 내비게이션 + 인증 가드 스켈레톤.
///
/// main.dart 초기화 예:
/// ```dart
/// await LocalStorageService.getInstance();
/// DioClient.instance.init(
///   tokenProvider: SecureStorageService.instance,
///   onTokenInvalidated: () => appRouter.go(AppRoutes.login),
/// );
/// runApp(MaterialApp.router(routerConfig: appRouter, theme: AppTheme.light));
/// ```
final GoRouter appRouter = GoRouter(
  //initialLocation: AppRoutes.login,
  initialLocation: '/room/test-room-123', // 임시 방 상세 화면
  //debugLogDiagnostics: true,
  redirect: _authRedirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const _PlaceholderScreen(title: '로그인'),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const _PlaceholderScreen(title: '회원가입'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const _PlaceholderScreen(title: '방 목록'),
    ),
    GoRoute(
      path: AppRoutes.roomCreate,
      builder: (_, __) => const _PlaceholderScreen(title: '방 만들기'),
    ),
    GoRoute(
      path: AppRoutes.roomJoin,
      builder: (_, __) => const _PlaceholderScreen(title: '초대 코드 입장'),
    ),
    GoRoute(
      path: AppRoutes.roomDetail,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? '';
        // TODO: RoomStatus에 따라 pre_start / finished 분기
        return GameMainScreen(roomId: roomId);
      },
      routes: [
        GoRoute(
          path: 'missions',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return _PlaceholderScreen(title: '미션 · $roomId');
          },
        ),
        GoRoute(
          path: 'notes',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return _PlaceholderScreen(title: '쪽지함 · $roomId');
          },
        ),
        GoRoute(
          path: 'hints',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return _PlaceholderScreen(title: '힌트 · $roomId');
          },
        ),
        GoRoute(
          path: 'results',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return _PlaceholderScreen(title: '결과 리포트 · $roomId');
          },
        ),
      ],
    ),
  ],
);

/// 인증 가드 — [SecureStorageService.hasAccessToken]
///
/// TODO: 온보딩 미완료 시 [LocalStorageService.isOnboardingCompleted] 분기 추가
/// TODO: refresh 실패 후 login 외 public 경로 화이트리스트 정교화
Future<String?> _authRedirect(BuildContext context, GoRouterState state) async {
  // final isLoggedIn = await SecureStorageService.instance.hasAccessToken();
  // final location = state.matchedLocation;

  // final isAuthRoute =
  //     location == AppRoutes.login || location == AppRoutes.register;

  // if (!isLoggedIn && !isAuthRoute) {
  //   return AppRoutes.login;
  // }

  // if (isLoggedIn && isAuthRoute) {
  //   return AppRoutes.home;
  // }

  return null;
}

/// Feature Screen 연결 전 임시 플레이스홀더
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'TODO: $title 화면 연결',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
