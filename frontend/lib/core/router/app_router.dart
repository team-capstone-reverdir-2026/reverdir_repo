import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/demo_set_screen.dart';
import '../../features/game_result/presentation/result_screen.dart';
import '../../features/hint/presentation/hint_collect_screen.dart';
import '../../features/letter/presentation/letter_board_screen.dart';
import '../../features/letter/presentation/letter_send_screen.dart';
import '../../features/main/presentation/main_page_screen.dart';
import '../../features/main/presentation/room_join_preview_screen.dart';
import '../../features/manitto_game/presentation/game_main_screen.dart';
import '../../features/room/presentation/mission_input_screen.dart';
import '../../features/room/presentation/room_create_screen.dart';
import '../../features/room/presentation/room_join_screen.dart';
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
  initialLocation: AppRoutes.login,
  //debugLogDiagnostics: true,
  redirect: _authRedirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const MainPageScreen(),
    ),
    GoRoute(
      path: AppRoutes.roomCreate,
      builder: (_, __) => const RoomCreateScreen(),
    ),
    GoRoute(
      path: AppRoutes.roomJoin,
      builder: (_, state) {
        final code = state.uri.queryParameters['code'] ?? '';
        return RoomJoinPreviewScreen(inviteCode: code);
      },
    ),
    GoRoute(
      path: AppRoutes.roomJoinProfile,
      builder: (_, state) {
        final roomId = state.uri.queryParameters['roomId'] ?? '';
        final code = state.uri.queryParameters['code'] ?? '';
        final missionCount = int.tryParse(
              state.uri.queryParameters['missionCount'] ?? '',
            ) ??
            1;
        return RoomJoinScreen(
          roomId: roomId,
          invitationCode: code,
          missionCount: missionCount,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.roomJoinMissions,
      builder: (_, state) {
        final roomId = state.uri.queryParameters['roomId'] ?? '';
        final missionCount = int.tryParse(
              state.uri.queryParameters['missionCount'] ?? '',
            ) ??
            1;
        final userName = state.uri.queryParameters['userName'] ?? '';
        final invitationCode = state.uri.queryParameters['code'] ?? '';
        return MissionInputScreen(
          roomId: roomId,
          missionCount: missionCount,
          userName: userName,
          invitationCode: invitationCode,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.roomDetail,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? '';
        final displayName = state.uri.queryParameters['displayName']?.trim();
        final inviteCode = state.uri.queryParameters['inviteCode']?.trim();
        return GameMainScreen(
          key: ValueKey(state.uri.toString()),
          roomId: roomId,
          myDisplayName:
              displayName == null || displayName.isEmpty ? null : displayName,
          inviteCodeQuery:
              inviteCode == null || inviteCode.isEmpty ? null : inviteCode,
        );
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
            return LetterBoardScreen(roomId: roomId);
          },
          routes: [
            GoRoute(
              path: 'send',
              builder: (context, state) {
                final roomId = state.pathParameters['roomId'] ?? '';
                return LetterSendScreen(roomId: roomId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'demo-admin',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return DemoSetScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'hints',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return HintCollectScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'results',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? '';
            return ResultScreen(roomId: roomId);
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
  final isLoggedIn = await SecureStorageService.instance.hasAccessToken();
  final location = state.matchedLocation;
  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.register;

  if (!isLoggedIn && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isLoggedIn && isAuthRoute) {
    return AppRoutes.home;
  }

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
