import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/recommendation_section.dart';

class _FixedResultRecommendations extends CertificateRecommendations {
  _FixedResultRecommendations(this.result);
  final CertificateRecommendationResult? result;

  @override
  Future<CertificateRecommendationResult?> build() async => result;
}

class _CountingGenerateRecommendations extends CertificateRecommendations {
  int generateCalls = 0;

  @override
  Future<CertificateRecommendationResult?> build() async =>
      const CertificateRecommendationResult(recommendationId: 1, items: []);

  @override
  Future<void> generate() async => generateCalls++;
}

class _ThrowingRecommendations extends CertificateRecommendations {
  _ThrowingRecommendations(this.error);
  final Object error;

  @override
  Future<CertificateRecommendationResult?> build() async => throw error;
}

void main() {
  const certificates = [
    Certificate(id: 'C001', name: '정보처리기사', category: 'IT'),
  ];

  Future<void> pumpSection(
    WidgetTester tester, {
    required CertificateRecommendations Function() recommendations,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          certificateRecommendationsProvider.overrideWith(recommendations),
          certificatesProvider.overrideWith((ref) async => certificates),
        ],
        child: const MaterialApp(home: Scaffold(body: RecommendationSection())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('추천 후보가 없다는 422 에러면 안내 문구와 무작위 자격증을 보여준다', (
    tester,
  ) async {
    await pumpSection(
      tester,
      recommendations: () => _ThrowingRecommendations(
        const ApiException(
          statusCode: 422,
          message: '추천 가능한 자격증이 없습니다.',
          code: 'NO_CANDIDATE_CERTIFICATE',
        ),
      ),
    );

    expect(find.text('추천드릴 자격증이 없습니다'), findsOneWidget);
    expect(find.text('정보처리기사'), findsOneWidget);
  });

  testWidgets('추천은 생성됐지만 항목이 비어 있으면 안내 문구와 무작위 자격증을 보여준다', (tester) async {
    await pumpSection(
      tester,
      recommendations: () => _FixedResultRecommendations(
        const CertificateRecommendationResult(recommendationId: 1, items: []),
      ),
    );

    expect(find.text('추천드릴 자격증이 없습니다'), findsOneWidget);
    expect(find.text('정보처리기사'), findsOneWidget);
  });

  testWidgets('온보딩 미완료(409)면 온보딩으로 안내하는 문구·버튼과 무작위 자격증을 보여준다', (
    tester,
  ) async {
    await pumpSection(
      tester,
      recommendations: () => _ThrowingRecommendations(
        const ApiException(
          statusCode: 409,
          message: '온보딩을 먼저 완료해 주세요.',
          code: 'ONBOARDING_NOT_COMPLETED',
        ),
      ),
    );

    expect(find.text('온보딩을 완료하면 더 정확히 추천해드려요'), findsOneWidget);
    expect(find.text('온보딩 하러 가기'), findsOneWidget);
    expect(find.text('다시 시도'), findsNothing);
    expect(find.text('정보처리기사'), findsOneWidget);
  });

  testWidgets('추천 후보 없음이 아닌 다른 에러는 기존 재시도 문구를 그대로 보여준다', (tester) async {
    await pumpSection(
      tester,
      recommendations: () =>
          _ThrowingRecommendations(const ApiException(message: '네트워크 오류')),
    );

    expect(find.text('추천을 불러오지 못했어요 · 다시 시도'), findsOneWidget);
    expect(find.text('추천드릴 자격증이 없습니다'), findsNothing);
  });

  testWidgets('추천을 만든 적이 없으면 만들기 카드를 보여준다', (tester) async {
    await pumpSection(
      tester,
      recommendations: () => _FixedResultRecommendations(null),
    );

    expect(find.text('나에게 맞는 자격증을 추천받아보세요'), findsOneWidget);
    expect(find.text('추천드릴 자격증이 없습니다'), findsNothing);
  });

  testWidgets('추천이 비어 있을 때 다시 시도하면 저장된 추천을 다시 읽지 않고 새로 만든다', (
    tester,
  ) async {
    final notifier = _CountingGenerateRecommendations();
    await pumpSection(tester, recommendations: () => notifier);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();

    expect(notifier.generateCalls, 1);
  });
}
