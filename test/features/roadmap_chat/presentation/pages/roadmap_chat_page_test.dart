import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/chat/data/chat_message.dart';
import 'package:li_on/features/roadmap_chat/presentation/pages/roadmap_chat_page.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_view_model.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/chat_input_bar.dart';

import '../../../../support/widget_test_helpers.dart';

/// 화면 높이를 훨씬 넘는 대화가, 화면이 뜬 뒤에 불러와지는 대화 내역.
class _FakeChatViewModel extends RoadmapChatViewModel {
  _FakeChatViewModel(super.session);

  @override
  RoadmapChatState build() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!ref.mounted) return;
      state = RoadmapChatState(
        sessionId: 1,
        messages: [
          for (int i = 0; i < 30; i++)
            ChatMessage(
              id: i,
              sender: i.isEven ? ChatSender.bot : ChatSender.user,
              text: '대화 $i번째 메시지예요',
              timestamp: DateTime(2026, 10, 8, 10),
            ),
        ],
      );
    });
    return const RoadmapChatState();
  }
}

void main() {
  Future<void> pumpChat(WidgetTester tester) async {
    useSmallPhone(tester, textScale: 1.3);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roadmapChatViewModelProvider.overrideWith2(_FakeChatViewModel.new),
        ],
        child: const MaterialApp(
          home: RoadmapChatPage(certificateName: '정보처리기사', historyId: 1),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
  }

  /// 마지막 메시지가 목록 영역 안에 온전히 들어와 있는지.
  void expectLastMessageVisible(WidgetTester tester) {
    final Finder last = find.textContaining('대화 29번째');
    expect(last, findsOneWidget);
    final Rect list = tester.getRect(find.byType(ListView));
    final Rect message = tester.getRect(last);
    expect(message.top, greaterThanOrEqualTo(list.top));
    expect(message.bottom, lessThanOrEqualTo(list.bottom));
  }

  testWidgets('대화를 불러오면 마지막 메시지가 입력창 바로 위에 온전히 보인다', (tester) async {
    await pumpChat(tester);

    expectLastMessageVisible(tester);
  });

  testWidgets('맨 아래를 보고 있으면 키보드가 올라와도 마지막 메시지가 계속 보인다', (tester) async {
    await pumpChat(tester);

    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    expectLastMessageVisible(tester);
    expect(
      tester.getRect(find.byType(ChatInputBar)).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
  });

  testWidgets('위로 올려 이전 대화를 보는 중이면 키보드가 올라와도 그 자리를 유지한다', (tester) async {
    await pumpChat(tester);
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    final ScrollableState scrollable = tester.state(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final double before = scrollable.position.pixels;

    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    expect(scrollable.position.pixels, closeTo(before, 0.5));
  });
}
