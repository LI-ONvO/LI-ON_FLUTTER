import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/notification/device_token_repository.dart';
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
  await PushNotificationService.initialize(
    onTokenRefresh: (token) {
      if (!container.read(authSessionProvider).isAuthenticated) return;
      container
          .read(deviceTokenRepositoryProvider)
          .register(token)
          .catchError((_) {});
    },
  );

  await precacheSplashLogo();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// 기기의 글자 크기 설정을 따르되, 이 배율까지만 키운다. 설정을 아주 크게 한
/// 기기에서 레이아웃이 깨지거나 잘리는 것을 막는다.
const double _maxTextScale = 1.3;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.read(authSessionProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: createAppRouter(authSession),
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: _maxTextScale,
        // 웹에서 창이 넓을 때만 화면을 휴대폰 폭으로 가운데 정렬한다.
        child: WebFrame(child: child ?? const SizedBox()),
      ),
    );
  }
}
