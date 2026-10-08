import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_search_view_model.dart';

/// category별 개수대로 자격증을 만든다. 빈 문자열은 category가 없는 자격증.
Future<ProviderContainer> _containerWith(
  Map<String, int> countByCategory,
) async {
  final certificates = [
    for (final entry in countByCategory.entries)
      for (int i = 0; i < entry.value; i++)
        Certificate(
          id: '${entry.key}$i',
          name: '${entry.key}$i',
          category: entry.key,
        ),
  ];
  final container = ProviderContainer(
    overrides: [certificatesProvider.overrideWith((ref) async => certificates)],
  );
  await container.read(certificatesProvider.future);
  return container;
}

void main() {
  test('카테고리 칩은 항목이 많은 category 상위 4개와 기타로 만든다', () async {
    final container = await _containerWith({
      '기사': 5,
      '기능사': 4,
      '기술사': 3,
      '기능장': 2,
      '경매사': 1,
      '': 1,
    });
    addTearDown(container.dispose);

    expect(container.read(certificateCategoriesProvider), [
      '전체',
      '기사',
      '기능사',
      '기술사',
      '기능장',
      '기타',
    ]);
  });

  test('모든 자격증이 칩에 들어가면 기타 칩을 만들지 않는다', () async {
    final container = await _containerWith({'기사': 2, '기능사': 1});
    addTearDown(container.dispose);

    expect(container.read(certificateCategoriesProvider), ['전체', '기사', '기능사']);
  });

  test('카테고리를 고르면 해당 자격증만, 기타를 고르면 칩에 없는 자격증만 보인다', () async {
    final container = await _containerWith({
      '기사': 5,
      '기능사': 4,
      '기술사': 3,
      '기능장': 2,
      '경매사': 1,
      '': 1,
    });
    addTearDown(container.dispose);
    final notifier = container.read(
      certificateSearchViewModelProvider.notifier,
    );
    List<String> shownCategories() => container
        .read(filteredCertificatesProvider)
        .requireValue
        .map((certificate) => certificate.category)
        .toList();

    expect(shownCategories(), hasLength(16));

    notifier.selectCategory('기사');
    expect(shownCategories(), everyElement('기사'));
    expect(shownCategories(), hasLength(5));

    notifier.selectCategory(otherCategory);
    expect(shownCategories(), unorderedEquals(['경매사', '']));
  });

  test('검색어 입력은 짧은 디바운스 뒤에 적용된다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(
      certificateSearchViewModelProvider.notifier,
    );

    notifier.setQuery('SQLD');
    expect(container.read(certificateSearchViewModelProvider).query, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(container.read(certificateSearchViewModelProvider).query, 'SQLD');
  });

  test('연속 입력은 마지막 검색어만 적용한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(
      certificateSearchViewModelProvider.notifier,
    );

    notifier.setQuery('정');
    notifier.setQuery('정보');
    notifier.setQuery('정보처리기사');

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(container.read(certificateSearchViewModelProvider).query, '정보처리기사');
  });
}
