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

  test('http·https 주소는 그대로 둔다', () {
    expect(
      resolveMaterialUrl('https://exam-archive.kr/x').toString(),
      'https://exam-archive.kr/x',
    );
    expect(
      resolveMaterialUrl('http://exam-archive.kr:8080/x').toString(),
      'http://exam-archive.kr:8080/x',
    );
    // 스킴 대소문자는 가리지 않는다.
    expect(resolveMaterialUrl('HTTPS://exam-archive.kr/x')?.scheme, 'https');
  });

  test('웹 주소가 아닌 스킴은 열지 않는다', () {
    expect(resolveMaterialUrl('file:///etc/passwd'), isNull);
    expect(resolveMaterialUrl('myapp://open?token=abc'), isNull);
    expect(resolveMaterialUrl('ftp://exam-archive.kr/x'), isNull);
  });
}
