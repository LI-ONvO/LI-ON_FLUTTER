import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/data/certificate_recommendation.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/my/data/info_edit.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/my/presentation/pages/my_page.dart';

void main() {
  const MethodChannel settingsChannel = MethodChannel(
    'com.spencerccf.app_settings/methods',
  );

  Future<void> pumpMyPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          certificateRepositoryProvider.overrideWithValue(
            _FakeCertificateRepository(),
          ),
          authSessionProvider.overrideWithValue(
            AuthSessionController()..restore(
              const AuthUser(
                userId: 1,
                email: 'user@example.com',
                nickname: '닉네임',
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: MyPage()),
      ),
    );
    await tester.pump();
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, null);
  });

  testWidgets('알림 설정을 누르면 시스템 알림 설정 화면을 연다', (tester) async {
    final List<MethodCall> calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (call) async {
          calls.add(call);
          return null;
        });
    await pumpMyPage(tester);

    expect(find.text('준비 중'), findsOneWidget); // 이용약관만 남는다.

    await tester.tap(find.text('알림 설정'));
    await tester.pump();

    expect(calls.single.method, 'openSettings');
    expect(calls.single.arguments['type'], 'notification');
  });

  testWidgets('시스템 설정을 열지 못하면 안내 스낵바를 보여준다', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (call) async {
          throw PlatformException(code: 'unavailable');
        });
    await pumpMyPage(tester);

    await tester.tap(find.text('알림 설정'));
    await tester.pump();

    expect(find.text('알림 설정을 열지 못했어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<Profile> fetchMyProfile() => Completer<Profile>().future;

  @override
  Future<InfoEditResponse> updateInfo(InfoEditRequest request) =>
      throw UnimplementedError();
}

class _FakeCertificateRepository implements CertificateRepository {
  @override
  Future<List<Certificate>> fetchCertificates({String? keyword}) async => [];

  @override
  Future<CertificateDetail?> fetchCertificateDetail(String id) async => null;

  @override
  Future<CertificateRecommendationResult?> fetchRecommendations() async => null;

  @override
  Future<CertificateRecommendationResult> createRecommendations({
    int size = 3,
  }) => throw UnimplementedError();
}
