import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/router/app_shell.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/auth/login/view/login_page.dart';
import 'package:li_on/pages/auth/provider/auth_session.dart';
import 'package:li_on/pages/auth/sign_up/view/email_verification_page.dart';
import 'package:li_on/pages/auth/sign_up/view/sign_up_page.dart';
import 'package:li_on/pages/calendar/view/calendar_page.dart';
import 'package:li_on/pages/certificate_search/view/certificate_detail_page.dart';
import 'package:li_on/pages/certificate_search/view/certificate_serch_page.dart';
import 'package:li_on/pages/data_room/view/data_room_page.dart';
import 'package:li_on/pages/data_room/view/material_detail_page.dart';
import 'package:li_on/pages/my/view/my_page.dart';
import 'package:li_on/pages/onboarding/view/onboarding_page.dart';
import 'package:li_on/pages/roadmap/chat_history/view/chat_history_page.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/view/roadmap_chat_page.dart';
import 'package:li_on/pages/splash/view/splash_page.dart';

/// 앱의 진입 경로. 로고를 잠깐 보여 준 뒤 [afterSplashLocation]으로 넘어간다.
const String initialLocation = '/splash';

GoRouter createAppRouter(AuthSessionController authSession) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: authSession,
  redirect: (context, state) {
    final bool isGuestRoute =
        state.matchedLocation == '/splash' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/sign-up' ||
        state.matchedLocation == '/sign-up/verify-email';
    if (state.matchedLocation == '/onboarding' &&
        !authSession.canAccessOnboarding) {
      return authSession.isAuthenticated ? '/search' : '/sign-up';
    }
    if (!authSession.isAuthenticated && !isGuestRoute) return '/login';
    if (authSession.isAuthenticated &&
        (state.matchedLocation == '/login' ||
            state.matchedLocation == '/sign-up' ||
            state.matchedLocation == '/sign-up/verify-email')) {
      return '/search';
    }
    return null;
  },
  routes: [
    // 앱의 첫 화면. 세션 확인 뒤 로그인 또는 탐색 화면으로 넘어간다.
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/sign-up', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/sign-up/verify-email',
      builder: (context, state) => const EmailVerificationPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // 셸 브랜치가 아니라 최상위(root) 네비게이터에 두는 라우트. 셸 브랜치
    // 안에 두면 AppShell의 하단 탭바가 계속 떠 있는 채로 겹쳐 보이므로,
    // 상세 화면이 탭바 없이 전체 화면으로 덮이도록 여기에 둔다.
    GoRoute(
      path: '/search/certificate/:certificateId',
      builder: (context, state) {
        // 딥링크 등으로 id가 비어 있어도 크래시 없이 안내 화면을 띄운다.
        final String? certificateId = state.pathParameters['certificateId'];
        if (certificateId == null || certificateId.isEmpty) {
          return const _InvalidRoutePage(title: '자격증 상세');
        }
        final Object? extra = state.extra;
        return CertificateDetailPage(
          certificateId: certificateId,
          initialTitle: extra is String ? extra : null,
        );
      },
    ),
    // 자료방 목록에서 고른 자료의 상세. 셸 브랜치의 '/materials'와 달리 하단
    // 탭바 없이 전체 화면으로 덮이도록 여기에 둔다.
    GoRoute(
      path: '/materials/:materialId',
      builder: (context, state) {
        final int? materialId = int.tryParse(
          state.pathParameters['materialId'] ?? '',
        );
        if (materialId == null) {
          return const _InvalidRoutePage(title: '자료 상세');
        }
        return MaterialDetailPage(materialId: materialId);
      },
    ),
    GoRoute(
      path: '/roadmap/history',
      builder: (context, state) => const ChatHistoryPage(),
    ),
    // 대화 내역에서 고른 자격증의 로드맵 대화를 연다. 셸 브랜치의 '/roadmap'과
    // 달리 자격증을 경로로 받으므로, 어떤 대화든 바로 이어서 볼 수 있다.
    GoRoute(
      path: '/roadmap/chat/:certificateName',
      builder: (context, state) => RoadmapChatPage(
        certificateName: state.pathParameters['certificateName']!,
        historyId: int.tryParse(state.uri.queryParameters['sessionId'] ?? ''),
        // 대화 내역에서 들어온 경우, 앱바의 대화 내역 버튼이 새 화면을
        // 쌓지 않고 이미 아래에 있는 대화 내역으로 돌아가게 한다.
        openedFromHistory: state.uri.queryParameters['from'] == 'history',
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // 탐색 (0)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const CertificateSearchPage(),
            ),
          ],
        ),
        // 로드맵 (1)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/roadmap',
              builder: (context, state) => const RoadmapChatPage(
                certificateName: '학습',
                isRootChat: true,
              ),
            ),
          ],
        ),
        // 자료방 (2)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/materials',
              builder: (context, state) => const DataRoomPage(),
            ),
          ],
        ),
        // 캘린더 (3)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
        // 프로필 (4)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const MyPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// 경로 파라미터가 잘못된 주소로 들어왔을 때 크래시 대신 보여 주는 화면.
class _InvalidRoutePage extends StatelessWidget {
  final String title;

  const _InvalidRoutePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(title: title),
      child: Center(child: Text('페이지를 찾을 수 없어요', style: AppTextStyle.subText)),
    );
  }
}
