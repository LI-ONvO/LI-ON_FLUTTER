import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_search_view_model.dart';

void main() {
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
