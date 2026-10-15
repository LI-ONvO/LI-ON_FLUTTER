import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/roadmap_chat/data/certificate_mention.dart';
import 'package:li_on/features/roadmap_chat/data/roadmap_chat_repository.dart';
import 'package:li_on/features/chat/data/chat_message.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_session.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_state.dart';

export 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_session.dart';
export 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_state.dart';

/// 첫 메시지의 자격증을 찾느라 전송이 지연되는 시간의 상한.
const Duration _certificateLookupTimeout = Duration(seconds: 5);

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
          text: _greeting(),
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  /// 자격증 상세를 거치지 않은 대화는 첫 메시지의 자격증 이름으로 자격증이
  /// 연결되므로, 이름을 정확히 말하도록 예시와 함께 안내한다. 이때
  /// certificateName은 자격증 이름이 아니라 탭 제목용 문구라 인사에 넣지 않는다.
  String _greeting() {
    if (session.jmCd != null) {
      return '안녕하세요! ${session.certificateName} 학습 로드맵을 함께 만들어볼게요. '
          '시험까지 남은 기간이 어느 정도인가요?';
    }
    return '안녕하세요! 학습 로드맵을 함께 만들어볼게요. '
        '어떤 자격증이고 시험까지 남은 기간이 어느 정도인가요?\n\n'
        '자격증 이름을 정확히 알려주셔야 로드맵을 만들 수 있어요. '
        '예: "정보처리기사를 3개월 뒤에 준비하려고 해요"';
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

  /// 자격증 목록을 받아 [text]에 언급된 자격증을 찾는다. 목록을 못 받거나
  /// 오래 걸려도 메시지 전송을 막지 않도록, 실패하면 못 찾은 것으로 본다.
  Future<Certificate?> _findMentionedCertificate(String text) async {
    try {
      final List<Certificate> certificates = await ref
          .read(certificateRepositoryProvider)
          .fetchCertificates()
          .timeout(_certificateLookupTimeout);
      return findMentionedCertificate(text, certificates);
    } catch (_) {
      return null;
    }
  }

  /// 지금까지의 대화를 버리고 인사말만 있는 새 대화로 되돌린다. 서버 세션은
  /// 첫 메시지를 보낼 때 새로 만들어진다.
  void startNewChat() => ref.invalidateSelf();

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
      String? jmCd = session.jmCd;
      if (_sessionId == null) {
        // 자격증 상세를 거치지 않은 대화는 자격증이 연결되지 않아 로드맵을
        // 만들 수 없다. 세션은 만들 때만 자격증을 붙일 수 있어, 첫 메시지에
        // 언급된 자격증을 찾아 같이 연결한다.
        final Certificate? mentioned = jmCd == null
            ? await _findMentionedCertificate(trimmed)
            : null;
        jmCd ??= mentioned?.id;
        _sessionId = await repository.createSession(
          certificateName: mentioned?.name ?? certificateName,
          jmCd: jmCd,
        );
      }
      final int sessionId = _sessionId!;

      final ChatMessage reply = await repository.sendMessage(
        sessionId: sessionId,
        content: trimmed,
      );

      if (!ref.mounted) return;
      state = state.copyWith(
        messages: [...state.messages, reply],
        isBotTyping: false,
        sessionId: sessionId,
        jmCd: jmCd,
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
