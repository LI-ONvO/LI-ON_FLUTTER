import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: home)));
}

bool isElevatedButtonEnabled(WidgetTester tester) {
  final ElevatedButton button = tester.widget<ElevatedButton>(
    find.byType(ElevatedButton),
  );
  return button.onPressed != null;
}

/// 키보드가 올라오면 남는 높이가 가장 빠듯한 작은 화면(iPhone SE 크기).
const double _smallPhoneHeight = 667;
const Size _smallPhoneSize = Size(375, _smallPhoneHeight);
const double _statusBarHeight = 20;
const double _keyboardHeight = 260;
const double _homeIndicatorHeight = 34;
const double _devicePixelRatio = 2;

/// 키보드 윗면의 y 좌표. [showKeyboard] 뒤에 이 위로 보여야 가려지지 않은 것이다.
const double keyboardTop = _smallPhoneHeight - _keyboardHeight;

/// 상태바 높이. 시트가 이 아래에서 시작하는지 볼 때 쓴다.
const double statusBarHeight = _statusBarHeight;

FakeViewPadding _padding({required bool keyboardUp}) => FakeViewPadding(
  top: _statusBarHeight * _devicePixelRatio,
  // iOS는 키보드가 올라오면 아래 안전영역(홈 인디케이터)을 0으로 준다.
  bottom: keyboardUp ? 0 : _homeIndicatorHeight * _devicePixelRatio,
);

/// 테스트 화면을 작은 휴대폰으로 맞추고, 끝나면 원래대로 돌려놓는다.
/// [textScale]로 시스템 글자 크기도 키울 수 있다(앱은 1.3배까지 따른다).
void useSmallPhone(WidgetTester tester, {double textScale = 1.0}) {
  tester.view.devicePixelRatio = _devicePixelRatio;
  tester.view.physicalSize = _smallPhoneSize * _devicePixelRatio;
  tester.view.padding = _padding(keyboardUp: false);
  tester.view.viewPadding = _padding(keyboardUp: false);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

/// 소프트웨어 키보드를 올린다. 입력창에 포커스를 준 뒤에 부른다.
Future<void> showKeyboard(WidgetTester tester) async {
  tester.view.viewInsets = const FakeViewPadding(
    bottom: _keyboardHeight * _devicePixelRatio,
  );
  tester.view.padding = _padding(keyboardUp: true);
  await tester.pumpAndSettle();
}
