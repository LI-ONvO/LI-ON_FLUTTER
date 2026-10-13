import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/notification/device_token_repository.dart';
import 'package:li_on/core/notification/notification_navigation.dart';
import 'package:li_on/core/notification/push_notification_service.dart';
import 'package:li_on/core/router/app_router.dart';
import 'package:li_on/core/widgets/layout/web_frame.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/auth/user_scoped_state_reset.dart';
import 'package:li_on/features/splash/presentation/pages/splash_page.dart';
import 'package:li_on/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // main()에서 FCM 토큰 갱신 콜백이 API 클라이언트/인증 상태에 접근할 수
  // 있도록, 위젯 트리와 같은 컨테이너를 미리 만들어 공유한다.
  final ProviderContainer container = ProviderContainer();
  resetUserScopedStateOnSignOut(container);
  // 알림은 부가 기능이라 초기화에 실패해도 앱은 떠야 한다.
  try {
    await PushNotificationService.initialize(
      onTokenRefresh: (token) {
        if (!container.read(authSessionProvider).isAuthenticated) return;
        container
            .read(deviceTokenRepositoryProvider)
            .register(token)
            .catchError((_) {});
      },
      onNotificationTap: (data) {
        final String? route = notificationRouteFromData(data);
        if (route == null) return;
        container.read(pendingNotificationRouteProvider.notifier).set(route);
      },
    );
  } catch (error) {
    debugPrint('[FCM] 알림 초기화에 실패했어요: $error');
  }

  await precacheSplashLogo();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// 기기의 글자 크기 설정을 따르되, 이 배율까지만 키운다. 설정을 아주 크게 한
/// 기기에서 레이아웃이 깨지거나 잘리는 것을 막는다.
const double _maxTextScale = 1.3;

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // 빌드마다 새로 만들면 화면 이동이 처음으로 돌아가므로 한 번만 만든다.
  late final GoRouter _router = createAppRouter(ref.read(authSessionProvider));

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  /// 앱이 떠 있는 동안 알림을 누르면 그 알림의 화면으로 이동한다. 스플래시 중에는
  /// 아직 세션을 복원하지 못했으므로 두고, 스플래시가 끝나며 꺼내 간다.
  void _openNotificationRoute(String? route) {
    if (route == null || _router.state.uri.path == '/splash') return;
    ref.read(pendingNotificationRouteProvider.notifier).take();
    _router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      pendingNotificationRouteProvider,
      (previous, route) => _openNotificationRoute(route),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: _maxTextScale,
        // 웹에서 창이 넓을 때만 화면을 휴대폰 폭으로 가운데 정렬한다.
        child: WebFrame(child: child ?? const SizedBox()),
      ),
    );
  }
}
