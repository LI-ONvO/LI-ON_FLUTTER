import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/notification/device_token_repository.dart';
import 'package:li_on/core/notification/push_notification_service.dart';
import 'package:li_on/core/router/app_router.dart';
import 'package:li_on/core/widgets/layout/web_frame.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/splash/presentation/pages/splash_page.dart';
import 'package:li_on/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // main()에서 FCM 토큰 갱신 콜백이 API 클라이언트/인증 상태에 접근할 수
  // 있도록, 위젯 트리와 같은 컨테이너를 미리 만들어 공유한다.
  final ProviderContainer container = ProviderContainer();
  await PushNotificationService.initialize(
    onTokenRefresh: (token) {
      if (!container.read(authSessionProvider).isAuthenticated) return;
      container.read(deviceTokenRepositoryProvider).register(token).catchError((
        _,
      ) {});
    },
  );

  await precacheSplashLogo();

  runApp(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.read(authSessionProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: createAppRouter(authSession),
      // 웹에서 창이 넓을 때만 화면을 휴대폰 폭으로 가운데 정렬한다.
      builder: (context, child) => WebFrame(child: child ?? const SizedBox()),
    );
  }
}
