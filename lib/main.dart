import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/router/app_router.dart';
import 'package:li_on/core/widgets/layout/web_frame.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      // 웹에서 창이 넓을 때만 화면을 휴대폰 폭으로 가운데 정렬한다.
      builder: (context, child) => WebFrame(child: child ?? const SizedBox()),
    );
  }
}
