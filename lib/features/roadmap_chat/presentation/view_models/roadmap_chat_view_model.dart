import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/roadmap_chat/data/roadmap_chat_repository.dart';
import 'package:li_on/features/roadmap/data/chat_message.dart';

export 'package:li_on/features/roadmap/data/chat_message.dart';

class RoadmapChatSession {
  const RoadmapChatSession({
    required this.certificateName,
    this.historyId,
    this.jmCd,
  });

  final String certificateName;

  /// 대화 내역에서 열었다면 그 서버 세션 ID. 새 대화면 null이고,
  /// 첫 메시지를 보낼 때 세션이 만들어진다.
  final int? historyId;

  /// 특정 자격증 상세에서 들어왔다면 그 자격증의 jmCd. 자료 추천처럼
  /// 자격증에 종속된 기능을 켤지 판단하는 데 쓴다.
  final String? jmCd;

  @override
  bool operator ==(Object other) {
    return other is RoadmapChatSession &&
        certificateName == other.certificateName &&
        historyId == other.historyId &&
        jmCd == other.jmCd;
  }

  @override
  int get hashCode => Object.hash(certificateName, historyId, jmCd);
}

class RoadmapChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;

  /// 서버에 만들어진 채팅 세션 ID. 첫 메시지를 보내기 전(새 대화)에는 null.
  final int? sessionId;

  /// 이 대화가 연결된 자격증의 jmCd. 자료 추천 진입점을 보여줄지 결정한다.
  final String? jmCd;

  const RoadmapChatState({
    this.messages = const [],
    this.isBotTyping = false,
    this.sessionId,
    this.jmCd,
  });

  RoadmapChatState copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    int? sessionId,
    String? jmCd,
  }) {
    return RoadmapChatState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      sessionId: sessionId ?? this.sessionId,
      jmCd: jmCd ?? this.jmCd,
    );
  }
}

/// 새 대화와 대화 내역의 각 세션별로 독립된 대화 상태를 갖는다.
class RoadmapChatViewModel extends Notifier<RoadmapChatState> {
  RoadmapChatViewModel(this.session);

  final RoadmapChatSession session;

  String get certificateName => session.certificateName;

  /// 서버 채팅 세션 ID. 대화 내역에서 열었으면 바로 있고, 새 대화면 첫
  /// 메시지를 보낼 때 만들어진다.
  int? _sessionId;

  @override
  RoadmapChatState build() {
    _sessionId = session.historyId;
    if (session.historyId != null) {
      // build는 동기라 여기서 기다릴 수 없으므로, 과거 메시지는 뒤에서
      // 불러와 상태를 갱신한다.
      Future.microtask(() => _loadHistory(session.historyId!));
      return RoadmapChatState(sessionId: session.historyId, jmCd: session.jmCd);
    }
    return RoadmapChatState(
      jmCd: session.jmCd,
      messages: [
        ChatMessage(
          id: 0,
          sender: ChatSender.bot,
          text:
              '안녕하세요! ${session.certificateName} 학습 로드맵을 함께 만들어볼게요. '
              '시험까지 남은 기간이 어느 정도인가요?',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> _loadHistory(int sessionId) async {
    try {
      final RoadmapChatSessionDetail detail = await ref
          .read(roadmapChatRepositoryProvider)
          .fetchSessionDetail(sessionId);
      if (!ref.mounted) return;
      state = state.copyWith(messages: detail.messages, jmCd: detail.jmCd);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        messages: [
          ChatMessage(
            id: 0,
            sender: ChatSender.bot,
            text: '대화 내용을 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
            timestamp: DateTime.now(),
          ),
        ],
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.isBotTyping) return;

    final ChatMessage userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch,
      sender: ChatSender.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    final List<ChatMessage> history = [...state.messages, userMessage];
    state = state.copyWith(messages: history, isBotTyping: true);

    try {
      final RoadmapChatRepository repository = ref.read(
        roadmapChatRepositoryProvider,
      );
      final int sessionId = _sessionId ??= await repository.createSession(
        certificateName: certificateName,
        jmCd: session.jmCd,
      );

      final ChatMessage reply = await repository.sendMessage(
        sessionId: sessionId,
        content: trimmed,
      );

      if (!ref.mounted) return;
      state = state.copyWith(
        messages: [...state.messages, reply],
        isBotTyping: false,
        sessionId: sessionId,
      );
    } catch (error) {
      // 응답에 실패해도 입력이 계속 막히지 않도록 typing 상태를 되돌리고,
      // 실패를 대화로 알려준다.
      if (!ref.mounted) return;
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch,
            sender: ChatSender.bot,
            text: _sendFailureMessage(error),
            timestamp: DateTime.now(),
          ),
        ],
        isBotTyping: false,
      );
    }
  }
}

/// 메시지 전송 실패를 대화에 보여줄 안내 문구로 바꾼다. 502는 백엔드가
/// AI 서버 응답을 받지 못한 일시적 실패라, 같은 질문을 다시 보내면
/// 대부분 해결되므로 재전송을 안내한다.
String _sendFailureMessage(Object error) {
  if (error is ApiException) {
    if (error.statusCode == 502) {
      return 'AI가 지금 답변을 만들지 못했어요. 잠시 후 같은 질문을 다시 보내주세요.';
    }
    return error.message;
  }
  return '답변을 가져오지 못했어요. 잠시 후 다시 시도해주세요.';
}

/// autoDispose를 붙이지 않아, 화면을 나갔다 다시 들어와도 같은 세션의
/// 대화 내역은 유지된다.
final roadmapChatViewModelProvider =
    NotifierProvider.family<
      RoadmapChatViewModel,
      RoadmapChatState,
      RoadmapChatSession
    >(RoadmapChatViewModel.new);
