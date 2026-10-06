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
