import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/chat/data/chat_message.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/chat_bubble.dart';

void main() {
  Future<void> pumpBubble(
    WidgetTester tester,
    String text, {
    ChatSender sender = ChatSender.bot,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChatBubble(
              message: ChatMessage(
                id: 1,
                sender: sender,
                text: text,
                timestamp: DateTime(2026, 11, 5, 20, 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 화면에 그려진 글자 전체를 이어 붙인다.
  String renderedText(WidgetTester tester) => tester
      .widgetList<RichText>(find.byType(RichText))
      .map((widget) => widget.text.toPlainText())
      .join('\n');

  /// [text]를 담은 조각의 스타일을 찾는다.
  TextStyle? styleOf(WidgetTester tester, String text) {
    TextStyle? found;
    for (final RichText widget in tester.widgetList(find.byType(RichText))) {
      widget.text.visitChildren((span) {
        if (span is TextSpan && span.text == text) found = span.style;
        return true;
      });
      final InlineSpan root = widget.text;
      if (root is TextSpan && root.text == text) found ??= root.style;
    }
    return found;
  }

  testWidgets('봇 메시지의 제목과 굵은 글씨는 기호 없이 서식으로 보인다', (tester) async {
    await pumpBubble(tester, '### 합격률\n- **필기 합격률**: 71.13%');

    final String rendered = renderedText(tester);
    expect(rendered, isNot(contains('#')));
    expect(rendered, isNot(contains('*')));
    expect(rendered, contains('합격률'));
    expect(styleOf(tester, '필기 합격률')?.fontWeight, FontWeight.w700);
  });

  testWidgets('봇 메시지의 한 줄 바꿈은 그대로 유지된다', (tester) async {
    await pumpBubble(tester, '첫째 줄\n둘째 줄');

    expect(renderedText(tester), contains('첫째 줄\n둘째 줄'));
  });

  testWidgets('봇 메시지의 번호 목록과 하위 목록이 보인다', (tester) async {
    await pumpBubble(tester, '1. **실기 준비**:\n   - 기출문제를 푸세요.');

    final String rendered = renderedText(tester);
    expect(rendered, contains('1.'));
    expect(rendered, contains('기출문제를 푸세요.'));
    expect(rendered, isNot(contains('- ')));
  });

  testWidgets('봇 메시지의 이미지는 내려받지 않고 대체 글만 보인다', (tester) async {
    await pumpBubble(tester, '![합격 안내](https://example.com/a.png)');

    expect(find.byType(Image), findsNothing);
    expect(renderedText(tester), contains('합격 안내'));
  });

  testWidgets('봇 메시지의 표와 코드 블록이 말풍선 폭을 넘겨도 오류가 없다', (tester) async {
    await pumpBubble(
      tester,
      '| 구분 | 합격률 |\n| --- | --- |\n| 필기 | 71.13% |\n\n'
      '```\n${'long_code_line_' * 20}\n```',
    );

    expect(tester.takeException(), isNull);
    expect(renderedText(tester), contains('71.13%'));
  });

  testWidgets('웹 주소가 아닌 링크는 열지 않고 안내한다', (tester) async {
    await pumpBubble(tester, '[파일](file:///etc/passwd)');

    await tester.tapOnText(find.textRange.ofSubstring('파일'));
    await tester.pump();

    expect(find.text('링크를 열지 못했어요'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('사용자 메시지는 입력한 글자 그대로 보인다', (tester) async {
    await pumpBubble(tester, '**굵게** ### 그대로', sender: ChatSender.user);

    expect(find.text('**굵게** ### 그대로'), findsOneWidget);
  });
}
