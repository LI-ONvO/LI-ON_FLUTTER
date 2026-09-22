import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/certificate_search/data/certificate_recommendation.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';

export 'package:li_on/features/certificate_search/data/certificate_recommendation.dart';

/// 탐색 화면 상단 "맞춤 추천" 섹션 상태. `data`가 null이면 아직 추천을
/// 만든 적이 없다는 뜻이라, 화면은 생성 버튼을 보여준다.
class CertificateRecommendations
    extends AsyncNotifier<CertificateRecommendationResult?> {
  @override
  Future<CertificateRecommendationResult?> build() {
    return ref.watch(certificateRepositoryProvider).fetchRecommendations();
  }

  /// 새 추천을 만든다. 온보딩 미완료(409)·후보 없음(422) 등은
  /// [AsyncError]로 전달돼 화면이 일반 오류와 같은 방식으로 보여준다.
  Future<void> generate() async {
    final CertificateRepository repository = ref.read(
      certificateRepositoryProvider,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.createRecommendations());
  }
}

final certificateRecommendationsProvider = AsyncNotifierProvider<
  CertificateRecommendations,
  CertificateRecommendationResult?
>(CertificateRecommendations.new);
