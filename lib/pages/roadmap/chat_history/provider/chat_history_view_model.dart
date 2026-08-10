import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap/chat_history/model/chat_history_item.dart';
import 'package:li_on/pages/roadmap/chat_history/provider/chat_history_repository.dart';

export 'package:li_on/pages/roadmap/chat_history/model/chat_history_item.dart';

class ChatHistoryState {
  final String query;

  const ChatHistoryState({this.query = ''});

  ChatHistoryState copyWith({String? query}) {
    return ChatHistoryState(query: query ?? this.query);
  }
}

class ChatHistoryViewModel extends Notifier<ChatHistoryState> {
  @override
  ChatHistoryState build() => const ChatHistoryState();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }
}

final chatHistoryViewModelProvider =
    NotifierProvider<ChatHistoryViewModel, ChatHistoryState>(
      ChatHistoryViewModel.new,
    );

/// 검색어 필터가 적용된 대화 내역 목록. 최근 대화가 위로 오도록 정렬한다.
/// 실제 데이터는 [chatHistoriesProvider]에서 오므로, 더미 데이터를 API 응답으로
/// 바꿔도 이 provider와 화면 코드는 그대로 동작한다.
final filteredChatHistoriesProvider =
    Provider<AsyncValue<List<ChatHistoryItem>>>((ref) {
      final ChatHistoryState filter = ref.watch(chatHistoryViewModelProvider);
      final AsyncValue<List<ChatHistoryItem>> historiesAsync = ref.watch(
        chatHistoriesProvider,
      );

      return historiesAsync.whenData((histories) {
        final List<ChatHistoryItem> filtered = histories
            .where((history) => history.matches(filter.query))
            .toList();
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return filtered;
      });
    });
