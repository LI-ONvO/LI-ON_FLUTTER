import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/widgets/search_bar/custom_search_bar.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/pages/certificate_detail_page.dart';
import 'package:li_on/features/certificate_search/presentation/pages/certificate_search_page.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_search_view_model.dart';
import 'package:li_on/features/chat/data/chat_message.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap_chat/data/roadmap_chat_repository.dart';
import 'package:li_on/features/roadmap_chat/presentation/pages/roadmap_chat_page.dart';

/// 세션 상세의 자격증과 메시지를 정해 두는 가짜 채팅 저장소.
class _FakeChatRepository implements RoadmapChatRepository {
  _FakeChatRepository({this.jmCd, this.failDetail = false});

  final String? jmCd;
  final bool failDetail;

  @override
  Future<int> createSession({
    required String certificateName,
    String? jmCd,
  }) async => 1;

  @override
  Future<RoadmapChatSessionDetail> fetchSessionDetail(int sessionId) async {
    if (failDetail) throw const ApiException(message: '실패');
    return (messages: <ChatMessage>[], jmCd: jmCd);
  }

  @override
  Future<ChatMessage> sendMessage({
    required int sessionId,
    required String content,
  }) => throw UnimplementedError();
}

/// 자격증 선택 요청을 기록하고, [error]가 있으면 그 오류로 실패한다.
class _FakeRoadmapRepository implements RoadmapRepository {
  _FakeRoadmapRepository({this.error});

  final Object? error;
  final List<(int, String)> selections = [];

  @override
  Future<void> selectSessionCertificate({
    required int sessionId,
    required String jmCd,
  }) async {
    if (error != null) throw error!;
    selections.add((sessionId, jmCd));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRecommendations extends CertificateRecommendations {
  @override
  Future<CertificateRecommendationResult?> build() async => null;
}

void main() {
  Future<void> pumpChat(
    WidgetTester tester, {
    required _FakeChatRepository chat,
    _FakeRoadmapRepository? roadmaps,
  }) async {
    // 앱의 라우트와 같은 구성: 탐색 화면은 검색 상태를 따로 갖는다.
    final GoRouter router = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(
          path: '/chat',
          builder: (context, state) =>
              const RoadmapChatPage(certificateName: '기타', historyId: 1),
        ),
        GoRoute(
          path: '/roadmap/select-certificate',
          builder: (context, state) => ProviderScope(
            overrides: [
              certificateSearchViewModelProvider,
              filteredCertificatesProvider,
            ],
            child: CertificateSearchPage(
              selectForSessionId: int.parse(
                state.uri.queryParameters['sessionId']!,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/search/certificate/:certificateId',
          builder: (context, state) => CertificateDetailPage(
            certificateId: state.pathParameters['certificateId']!,
            initialTitle: state.extra as String?,
            selectForSessionId: int.tryParse(
              state.uri.queryParameters['selectForSession'] ?? '',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roadmapChatRepositoryProvider.overrideWithValue(chat),
          roadmapRepositoryProvider.overrideWithValue(
            roadmaps ?? _FakeRoadmapRepository(),
          ),
          certificatesProvider.overrideWith(
            (ref) async => const [
              Certificate(id: 'C1', name: '정보처리기사', category: '기사'),
              Certificate(id: 'C2', name: '전기기사', category: '기사'),
            ],
          ),
          certificateDetailProvider.overrideWith(
            (ref, id) async => null as CertificateDetail?,
          ),
          certificateRecommendationsProvider.overrideWith(
            _NoRecommendations.new,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(_plusButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('정보처리기사'));
    await tester.pumpAndSettle();
  }

  testWidgets('자격증이 없는 세션이면 제목 옆에 + 버튼을 보여준다', (tester) async {
    await pumpChat(tester, chat: _FakeChatRepository());

    expect(_plusButton(), findsOneWidget);
  });

  testWidgets('자격증이 연결된 세션이면 + 버튼을 보여주지 않는다', (tester) async {
    await pumpChat(tester, chat: _FakeChatRepository(jmCd: 'C1'));

    expect(_plusButton(), findsNothing);
  });

  testWidgets('세션 상세를 불러오지 못하면 + 버튼을 보여주지 않는다', (tester) async {
    await pumpChat(tester, chat: _FakeChatRepository(failDetail: true));

    expect(_plusButton(), findsNothing);
  });

  testWidgets('탐색·상세를 거쳐 자격증을 선택하면 대화로 돌아와 반영된다', (tester) async {
    final roadmaps = _FakeRoadmapRepository();
    await pumpChat(tester, chat: _FakeChatRepository(), roadmaps: roadmaps);

    await openDetail(tester);
    expect(find.text('로드맵 만들기'), findsNothing);

    await tester.tap(find.text('자격증 선택하기'));
    await tester.pumpAndSettle();

    expect(roadmaps.selections, [(1, 'C1')]);
    expect(find.byType(RoadmapChatPage), findsOneWidget);
    expect(find.text('정보처리기사 로드맵'), findsOneWidget);
    expect(_plusButton(), findsNothing);
  });

  testWidgets('선택에 실패하면 상세에 남아 다시 시도할 수 있다', (tester) async {
    await pumpChat(
      tester,
      chat: _FakeChatRepository(),
      roadmaps: _FakeRoadmapRepository(
        error: const ApiException(
          statusCode: 422,
          message: '서버 문구',
          code: 'CERTIFICATE_ALREADY_EXISTS',
        ),
      ),
    );

    await openDetail(tester);
    await tester.tap(find.text('자격증 선택하기'));
    await tester.pump();
    await tester.pump();

    expect(find.text('이미 자격증이 선택된 대화예요'), findsOneWidget);
    expect(find.byType(CertificateDetailPage), findsOneWidget);
    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('탐색 탭의 검색 상태가 자격증 선택 화면에 섞이지 않는다', (tester) async {
    await pumpChat(tester, chat: _FakeChatRepository());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RoadmapChatPage)),
    );
    container
        .read(certificateSearchViewModelProvider.notifier)
        .selectCategory('없는 카테고리');

    await tester.tap(_plusButton());
    await tester.pumpAndSettle();

    expect(find.byType(CustomSearchBar), findsOneWidget);
    expect(find.text('정보처리기사'), findsOneWidget);
  });
}

Finder _plusButton() => find.byIcon(Icons.add);
