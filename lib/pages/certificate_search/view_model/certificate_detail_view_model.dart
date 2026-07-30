import 'package:flutter_riverpod/flutter_riverpod.dart';

class CertificateDetailState {
  final bool isBookmarked;

  const CertificateDetailState({this.isBookmarked = false});

  CertificateDetailState copyWith({bool? isBookmarked}) {
    return CertificateDetailState(
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

/// [certificateId]별로 독립된 북마크 상태를 갖는다.
class CertificateDetailViewModel extends Notifier<CertificateDetailState> {
  CertificateDetailViewModel(this.certificateId);

  final String certificateId;

  @override
  CertificateDetailState build() => const CertificateDetailState();

  void toggleBookmark() {
    state = state.copyWith(isBookmarked: !state.isBookmarked);
  }
}

/// autoDispose를 붙이지 않아, 화면을 나갔다 다시 들어와도 같은 [certificateId]의
/// 북마크 상태는 유지된다 (다른 certificateId와는 [family]로 격리된다).
final certificateDetailViewModelProvider = NotifierProvider.family<
    CertificateDetailViewModel, CertificateDetailState, String>(
  (certificateId) => CertificateDetailViewModel(certificateId),
);
