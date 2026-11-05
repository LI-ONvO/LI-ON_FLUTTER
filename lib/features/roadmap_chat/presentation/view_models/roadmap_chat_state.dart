import 'package:li_on/features/chat/data/chat_message.dart';

class RoadmapChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;

  /// 서버에 만들어진 채팅 세션 ID. 첫 메시지를 보내기 전(새 대화)에는 null.
  final int? sessionId;

  /// 이 대화가 연결된 자격증의 jmCd. 자료 추천 진입점을 보여줄지 결정한다.
  final String? jmCd;

  /// 사용자가 고른 자격증 이름. 있으면 화면 제목을 이 이름으로 바꿔 보여준다.
  final String? certificateName;

  /// 서버 세션의 자격증 연결 여부를 확인했는지. 내역을 불러오기 전이나 불러오지
  /// 못했을 때는 jmCd가 null이어도 자격증이 없다고 단정할 수 없다.
  final bool isCertificateChecked;

  const RoadmapChatState({
    this.messages = const [],
    this.isBotTyping = false,
    this.sessionId,
    this.jmCd,
    this.certificateName,
    this.isCertificateChecked = false,
  });

  /// 서버 세션에 자격증이 연결되어 있지 않아 직접 고를 수 있는 상태인지.
  bool get canSelectCertificate =>
      isCertificateChecked && sessionId != null && jmCd == null;

  RoadmapChatState copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    int? sessionId,
    String? jmCd,
    String? certificateName,
    bool? isCertificateChecked,
  }) {
    return RoadmapChatState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      sessionId: sessionId ?? this.sessionId,
      jmCd: jmCd ?? this.jmCd,
      certificateName: certificateName ?? this.certificateName,
      isCertificateChecked: isCertificateChecked ?? this.isCertificateChecked,
    );
  }
}
