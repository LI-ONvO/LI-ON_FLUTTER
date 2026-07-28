import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/pages/onboarding/view/onboarding_page.dart';

import '../../../support/widget_test_helpers.dart';

bool _isBadgeSelected(WidgetTester tester, String field) {
  final CustomBadge badge = tester.widget<CustomBadge>(
    find.widgetWithText(CustomBadge, field),
  );
  return badge.selected;
}

void main() {
  Future<void> pumpOnboardingPage(WidgetTester tester) =>
      pumpApp(tester, const OnboardingPage());

  group('다음 버튼 활성화', () {
    testWidgets('처음에는 비활성화 상태다', (tester) async {
      await pumpOnboardingPage(tester);

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('분야를 하나 선택하면 활성화된다', (tester) async {
      await pumpOnboardingPage(tester);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isTrue);
    });

    testWidgets('선택했던 분야를 다시 누르면 비활성화된다', (tester) async {
      await pumpOnboardingPage(tester);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();
      expect(isElevatedButtonEnabled(tester), isTrue);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isFalse);
    });
  });

  group('복수 선택', () {
    testWidgets('여러 분야를 동시에 선택할 수 있다', (tester) async {
      await pumpOnboardingPage(tester);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();
      await tester.tap(find.text('경영·회계'));
      await tester.pump();

      expect(_isBadgeSelected(tester, 'IT·정보통신'), isTrue);
      expect(_isBadgeSelected(tester, '경영·회계'), isTrue);
      expect(isElevatedButtonEnabled(tester), isTrue);
    });

    testWidgets('한 분야를 해제해도 다른 선택은 유지된다', (tester) async {
      await pumpOnboardingPage(tester);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();
      await tester.tap(find.text('경영·회계'));
      await tester.pump();

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();

      expect(_isBadgeSelected(tester, 'IT·정보통신'), isFalse);
      expect(_isBadgeSelected(tester, '경영·회계'), isTrue);
      expect(isElevatedButtonEnabled(tester), isTrue);
    });
  });
}
