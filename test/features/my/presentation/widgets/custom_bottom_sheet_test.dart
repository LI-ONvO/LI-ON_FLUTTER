import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/features/my/data/desired_fields_update_result.dart';
import 'package:li_on/features/my/data/info_edit.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/my/presentation/widgets/custom_bottom_sheet.dart';

void main() {
  const AuthUser user = AuthUser(
    userId: 1,
    email: 'user@example.com',
    nickname: '예전닉네임',
  );

  late _FakeUserRepository repository;
  late _MemoryTokenStorage storage;
  late AuthSessionController session;
  String? sheetResult;

  Future<void> pumpAndOpenSheet(WidgetTester tester) async {
    repository = _FakeUserRepository();
    storage = _MemoryTokenStorage();
    session = AuthSessionController()..restore(user);
    sheetResult = null;
    final ProviderContainer container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(repository),
        tokenStorageProvider.overrideWithValue(storage),
        authSessionProvider.overrideWithValue(session),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  sheetResult = await showAppBottomSheet<String>(
                    context: context,
                    builder: (context) => CustomBottomSheet(
                      name: user.nickname,
                      email: user.email,
                    ),
                  );
                },
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
  }

  Future<void> enterNicknameAndSave(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextFormField).first, name);
    await tester.tap(find.text('저장'));
    await tester.pump();
  }

  testWidgets('저장에 성공하면 세션·기기 저장소를 갱신하고 새 닉네임으로 닫힌다', (tester) async {
    await pumpAndOpenSheet(tester);

    await enterNicknameAndSave(tester, '새닉네임');
    repository.complete('새닉네임');
    await tester.pumpAndSettle();

    expect(repository.requestedNickname, '새닉네임');
    expect(session.user?.nickname, '새닉네임');
    expect(storage.savedUser?.nickname, '새닉네임');
    expect(sheetResult, '새닉네임');
    expect(find.byType(CustomBottomSheet), findsNothing);
  });

  testWidgets('저장 중에 시트를 닫아도 서버 저장이 끝나면 세션·기기 저장소를 갱신한다', (tester) async {
    await pumpAndOpenSheet(tester);

    await enterNicknameAndSave(tester, '새닉네임');
    // 응답이 오기 전에 시트 바깥(배경)을 눌러 닫는다.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomSheet), findsNothing);

    repository.complete('새닉네임');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(session.user?.nickname, '새닉네임');
    expect(storage.savedUser?.nickname, '새닉네임');
  });

  testWidgets('기기 저장소 쓰기가 실패해도 서버에 저장됐으면 시트를 닫는다', (tester) async {
    await pumpAndOpenSheet(tester);
    storage.failOnSave = true;

    await enterNicknameAndSave(tester, '새닉네임');
    repository.complete('새닉네임');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(sheetResult, '새닉네임');
    expect(find.byType(CustomBottomSheet), findsNothing);
    expect(find.text('저장 중...'), findsNothing);
  });
}

class _FakeUserRepository implements UserRepository {
  final Completer<InfoEditResponse> _response = Completer<InfoEditResponse>();
  String? requestedNickname;

  void complete(String nickname) {
    _response.complete(InfoEditResponse(id: 1, nickname: nickname));
  }

  @override
  Future<InfoEditResponse> updateInfo(InfoEditRequest request) {
    requestedNickname = request.nickname;
    return _response.future;
  }

  @override
  Future<Profile> fetchMyProfile() => Completer<Profile>().future;

  @override
  Future<DesiredFieldsUpdateResult> updateDesiredFields(
    List<int> desiredFieldIds,
  ) => throw UnimplementedError();
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage() : super(const FlutterSecureStorage());

  AuthUser? savedUser;
  bool failOnSave = false;

  @override
  Future<void> saveUser(AuthUser user) async {
    if (failOnSave) throw PlatformException(code: 'keychain-error');
    savedUser = user;
  }
}
