import 'package:go_router/go_router.dart';
import 'package:li_on/core/router/app_shell.dart';
import 'package:li_on/core/widgets/layout/coming_soon_page.dart';
import 'package:li_on/pages/auth/login/view/login_page.dart';
import 'package:li_on/pages/auth/sign_in/view/sign_in_page.dart';
import 'package:li_on/pages/certificate_search/view/certificate_detail_page.dart';
import 'package:li_on/pages/certificate_search/view/certificate_serch_page.dart';
import 'package:li_on/pages/my/view/my_page.dart';
import 'package:li_on/pages/onboarding/view/onboarding_page.dart';
import 'package:li_on/pages/roadmap_chat/view/roadmap_chat_page.dart';

/// 앱의 진입 경로. 로그인 상태를 판별하는 기능이 아직 없어 우선 하단 탭
/// 셸(프로필 탭)로 바로 진입한다. 로그인 게이팅이 생기면 '/login'으로 바꾼다.
const String initialLocation = '/profile';

final GoRouter appRouter = GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // 셸 브랜치가 아니라 최상위(root) 네비게이터에 두는 라우트. 셸 브랜치
    // 안에 두면 AppShell의 하단 탭바가 계속 떠 있는 채로 겹쳐 보이므로,
    // 상세 화면이 탭바 없이 전체 화면으로 덮이도록 여기에 둔다.
    GoRoute(
      path: '/search/certificate/:certificateId',
      builder: (context, state) => CertificateDetailPage(
        certificateId: state.pathParameters['certificateId']!,
        initialTitle: state.extra as String?,
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
              // 로그인 기능이 아직 없어 임시로 고정값을 전달한다.
              builder: (context, state) =>
                  const CertificateSearchPage(userName: '최승우'),
            ),
          ],
        ),
        // 로드맵 (1)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/roadmap',
              // 학습 중인 자격증을 선택하는 기능이 아직 없어 임시로 고정값을 전달한다.
              builder: (context, state) =>
                  const RoadmapChatPage(certificateName: '정보처리기사'),
            ),
          ],
        ),
        // 자료방 (2)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/materials',
              builder: (context, state) => const ComingSoonPage(title: '자료방'),
            ),
          ],
        ),
        // 캘린더 (3)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const ComingSoonPage(title: '캘린더'),
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
