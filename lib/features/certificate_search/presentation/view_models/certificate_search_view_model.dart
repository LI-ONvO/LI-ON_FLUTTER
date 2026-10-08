import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';

export 'package:li_on/features/certificate_search/data/certificate.dart';

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
  Timer? _searchDebounce;

  @override
  CertificateSearchState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    return const CertificateSearchState();
  }

  void setQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => state = state.copyWith(query: query),
    );
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final certificateSearchViewModelProvider =
    NotifierProvider<CertificateSearchViewModel, CertificateSearchState>(
      CertificateSearchViewModel.new,
    );

/// 칩으로 따로 보여줄 category 수. 이보다 드문 category는 '기타'로 묶는다.
const int _categoryChipLimit = 4;

/// 카테고리 칩 목록: '전체', 항목이 많은 category 상위 [_categoryChipLimit]개,
/// 그 밖의 자격증이 있으면 '기타'.
/// 서버가 내려주는 category 값은 바뀔 수 있어 하드코딩하지 않고 응답에서 뽑는다.
final certificateCategoriesProvider = Provider<List<String>>((ref) {
  final List<Certificate> certificates =
      ref.watch(certificatesProvider).value ?? const [];
  final Map<String, int> counts = {};
  for (final certificate in certificates) {
    if (certificate.category.isEmpty) continue;
    counts.update(
      certificate.category,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  final List<String> top =
      (counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!)))
          .take(_categoryChipLimit)
          .toList();
  return [
    allCategory,
    ...top,
    if (certificates.any((certificate) => !top.contains(certificate.category)))
      otherCategory,
  ];
});

/// 검색어·카테고리 필터가 적용된 자격증 목록.
/// 실제 데이터는 [certificatesProvider]에서 오므로, 더미 데이터를 API 응답으로
/// 바꿔도 이 provider와 화면 코드는 그대로 동작한다.
final filteredCertificatesProvider = Provider<AsyncValue<List<Certificate>>>((
  ref,
) {
  final filter = ref.watch(certificateSearchViewModelProvider);
  final categories = ref.watch(certificateCategoriesProvider);
  final certificatesAsync = ref.watch(certificatesProvider);

  return certificatesAsync.whenData((certificates) {
    // 앞뒤 공백과 대소문자 차이 때문에 검색이 실패하지 않도록 정규화한다.
    final String query = filter.query.trim().toLowerCase();
    return certificates.where((certificate) {
      final bool matchesCategory = switch (filter.selectedCategory) {
        allCategory => true,
        // 칩에 없는 category(빈 값 포함)가 모두 '기타'다.
        otherCategory => !categories.contains(certificate.category),
        final selected => certificate.category == selected,
      };
      final matchesQuery =
          query.isEmpty || certificate.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});
