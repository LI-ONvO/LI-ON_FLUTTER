import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/router/app_shell.dart';
import 'package:li_on/core/widgets/card/custom_card.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/pages/certificate_search_page.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';

import '../../../../support/widget_test_helpers.dart';

class _FixedRecommendations extends CertificateRecommendations {
  @override
  Future<CertificateRecommendationResult?> build() async =>
      const CertificateRecommendationResult(
        recommendationId: 1,
        items: [
          CertificateRecommendationItem(
            jmCd: 'S1',
            name: '컴퓨터시스템기사',
            category: '기사',
            reason: '정보기술 분야에 관심이 많고 기초를 배운 경험이 있어 추천해요',
          ),
        ],
      );
}

void main() {
  final List<Certificate> certificates = [
    for (int i = 0; i < 30; i++)
      Certificate(id: 'C$i', name: '자격증 $i', category: '기사'),
  ];

  /// 탭 셸 안에서 연다. 키보드가 올라올 때 남는 높이가 실제 앱과 같아야 한다.
  Future<void> pumpPage(WidgetTester tester) async {
    useSmallPhone(tester, textScale: 1.3);
    final GoRouter router = GoRouter(
      initialLocation: '/search',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const CertificateSearchPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          certificateRecommendationsProvider.overrideWith(
            _FixedRecommendations.new,
          ),
          certificatesProvider.overrideWith((ref) async => certificates),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 추천 카드가 접히면 그만큼 검색창이 위로 올라온다.
  double searchTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(TextField)).dy;

  /// 키보드 위에 온전히 보이는 검색 결과 카드 수.
  int visibleResultCount(WidgetTester tester) => tester
      .widgetList(find.byType(CustomCard))
      .map((card) => tester.getRect(find.byWidget(card)))
      .where((rect) => rect.bottom <= keyboardTop)
      .length;

  testWidgets('검색창을 누르면 추천 카드를 접어 키보드 위에 결과가 보인다', (tester) async {
    await pumpPage(tester);
    final double expandedTop = searchTop(tester);

    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    expect(searchTop(tester), lessThan(expandedTop - 100));
    expect(visibleResultCount(tester), greaterThanOrEqualTo(2));
  });

  testWidgets('검색을 마치면 추천 카드가 다시 펼쳐진다', (tester) async {
    await pumpPage(tester);
    final double expandedTop = searchTop(tester);
    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(searchTop(tester), closeTo(expandedTop, 1));
  });
}
