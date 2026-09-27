import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/features/onboarding/data/onboarding_question.dart';
import 'package:li_on/features/onboarding/data/onboarding_repository.dart';
import 'package:li_on/features/onboarding/data/onboarding_submit_result.dart';
import 'package:li_on/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../../../support/widget_test_helpers.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  int submitCalls = 0;
  List<OnboardingAnswer>? lastAnswers;

  @override
  Future<List<OnboardingQuestion>> fetchQuestions() async {
    return const [
      OnboardingQuestion(
        id: 1,
        key: 'interestedField',
        title: '어떤 분야에 관심이 있나요?',
        minSelect: 1,
        maxSelect: 8,
        options: [
          OnboardingQuestionOption(key: 'it', value: 'IT', label: 'IT·정보통신'),
          OnboardingQuestionOption(
            key: 'biz',
            value: 'BIZ',
            label: '경영·회계',
          ),
        ],
      ),
    ];
  }

  @override
  Future<OnboardingSubmitResult> submitAnswers(
    List<OnboardingAnswer> answers,
  ) async {
    submitCalls += 1;
    lastAnswers = answers;
    return const OnboardingSubmitResult(desiredFields: []);
  }
}

bool _isBadgeSelected(WidgetTester tester, String field) {
  final CustomBadge badge = tester.widget<CustomBadge>(
    find.widgetWithText(CustomBadge, field),
  );
  return badge.selected;
}

void main() {
  Future<_FakeOnboardingRepository> pumpOnboardingPage(
    WidgetTester tester,
  ) async {
    final repository = _FakeOnboardingRepository();
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // 질문 목록을 불러오는 FutureProvider가 정착할 때까지 기다린다.
    await tester.pumpAndSettle();
    return repository;
  }

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

  group('제출', () {
    testWidgets('다음을 누르면 선택한 답변을 제출하고 로그인 화면으로 이동한다', (tester) async {
      final repository = await pumpOnboardingPage(tester);

      await tester.tap(find.text('IT·정보통신'));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(repository.submitCalls, 1);
      expect(repository.lastAnswers, [
        isA<OnboardingAnswer>()
            .having((a) => a.questionKey, 'questionKey', 'interestedField')
            .having((a) => a.optionValues, 'optionValues', ['IT']),
      ]);
      expect(find.byType(OnboardingPage), findsNothing);
    });
  });
}
