import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/data_room/widget/material_link_card.dart';

void main() {
  test('스킴이 없는 주소에는 https를 붙인다', () {
    expect(
      resolveMaterialUrl('exam-archive.kr/info-processing-2026').toString(),
      'https://exam-archive.kr/info-processing-2026',
    );
  });

  test('포트가 붙어 있어도 호스트를 스킴으로 오해하지 않는다', () {
    expect(
      resolveMaterialUrl('exam-archive.kr:8080/path').toString(),
      'https://exam-archive.kr:8080/path',
    );
    expect(
      resolveMaterialUrl('localhost:3000/a').toString(),
      'https://localhost:3000/a',
    );
  });

  test('스킴이 이미 있는 주소는 그대로 둔다', () {
    expect(
      resolveMaterialUrl('https://exam-archive.kr/x').toString(),
      'https://exam-archive.kr/x',
    );
    expect(
      resolveMaterialUrl('http://exam-archive.kr:8080/x').toString(),
      'http://exam-archive.kr:8080/x',
    );
  });
}
