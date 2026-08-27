import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:li_on/main.dart' as app;

/// 실제 앱을 띄워 로그인부터 로그아웃까지 주요 흐름을 서버(API)와 함께
/// 검증한다. `--dart-define=API_BASE_URL`이 가리키는 서버가 떠 있어야 한다.
///
/// 실행: flutter test integration_test -d <기기 id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// [finder]가 나타날 때까지 최대 [timeout]만큼 화면을 갱신하며 기다린다.
  /// 스플래시 지연·네트워크 응답처럼 pumpAndSettle로 잡히지 않는 비동기
  /// 완료를 기다릴 때 쓴다.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    // 진단을 돕기 위해 현재 화면의 텍스트를 함께 남긴다.
    final List<String> visible = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
    fail('시간 안에 나타나지 않았어요: $finder\n현재 화면 텍스트: $visible');
  }

  Future<void> goTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('로그인부터 로그아웃까지 전체 기능이 서버와 함께 동작한다', (tester) async {
    app.main();

    // 스플래시가 끝나고 로그인 화면이 뜬다. 이전 실행의 토큰이 남아 있으면
    // 바로 탐색 화면으로 갈 수 있으므로 두 경우 모두 허용한다.
    await waitFor(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == '로그인' ||
                (widget.data?.startsWith('안녕하세요') ?? false)),
      ),
    );

    // ── 1. 로그인 ──
    if (find.text('로그인').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextFormField).first, 'test@lion.dev');
      await tester.enterText(find.byType(TextFormField).last, 'password1');
      await tester.pump();
      await tester.tap(find.text('로그인'));
      await waitFor(tester, find.textContaining('안녕하세요'));
    }

    // ── 2. 자격증 검색: 서버 목록이 보인다 ──
    await waitFor(tester, find.text('정보처리기사'));
    expect(find.text('SQLD'), findsWidgets);

    // ── 3. 자격증 상세 ──
    await tester.tap(find.text('정보처리기사').first);
    await waitFor(tester, find.text('시험 정보'));
    expect(find.text('시험 과목'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // ── 4. 로드맵 채팅: 세션 생성 + AI 응답 ──
    await goTab(tester, '로드맵');
    await waitFor(tester, find.textContaining('학습 로드맵을 함께'));
    await tester.enterText(find.byType(TextField).last, '3개월 계획 짜줘');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await waitFor(tester, find.textContaining('AI 답변'));

    // ── 5. 자료방: 서버 자료 목록 ──
    await goTab(tester, '자료방');
    await waitFor(tester, find.text('정보처리기사 기출 모음'));
    expect(find.text('SQLD 요약 노트'), findsWidgets);

    // ── 6. 캘린더: 서버 일정 조회 ──
    await goTab(tester, '캘린더');
    await waitFor(tester, find.text('SQLD 접수'));

    // ── 7. 프로필 → 로그아웃 ──
    await goTab(tester, '프로필');
    await waitFor(tester, find.text('로그아웃'));
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    // 확인 다이얼로그의 로그아웃 버튼(마지막 항목)을 누른다.
    await tester.tap(find.text('로그아웃').last);
    await waitFor(tester, find.text('로그인'));
  });
}
