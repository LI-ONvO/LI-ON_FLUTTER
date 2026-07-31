import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/certificate_search/model/certificate.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_repository.dart';

export 'package:li_on/pages/certificate_search/model/certificate.dart';

class CertificateSearchState {
  final String query;
  final String selectedCategory;

  const CertificateSearchState({
    this.query = '',
    this.selectedCategory = allCategory,
  });

  CertificateSearchState copyWith({String? query, String? selectedCategory}) {
    return CertificateSearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class CertificateSearchViewModel extends Notifier<CertificateSearchState> {
  @override
  CertificateSearchState build() => const CertificateSearchState();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final certificateSearchViewModelProvider =
    NotifierProvider<CertificateSearchViewModel, CertificateSearchState>(
      CertificateSearchViewModel.new,
    );

/// 검색어·카테고리 필터가 적용된 자격증 목록.
/// 실제 데이터는 [certificatesProvider]에서 오므로, 더미 데이터를 API 응답으로
/// 바꿔도 이 provider와 화면 코드는 그대로 동작한다.
final filteredCertificatesProvider = Provider<AsyncValue<List<Certificate>>>((
  ref,
) {
  final filter = ref.watch(certificateSearchViewModelProvider);
  final certificatesAsync = ref.watch(certificatesProvider);

  return certificatesAsync.whenData((certificates) {
    return certificates.where((certificate) {
      final matchesCategory =
          filter.selectedCategory == allCategory ||
          certificate.category == filter.selectedCategory;
      final matchesQuery =
          filter.query.isEmpty || certificate.name.contains(filter.query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});
