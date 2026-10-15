import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/roadmap_chat/data/certificate_mention.dart';

Certificate _cert(String id, String name, {String qualGbCd = 'T'}) =>
    Certificate(id: id, name: name, category: 'IT', qualGbCd: qualGbCd);

void main() {
  final List<Certificate> certificates = [
    _cert('1', '정보처리기사'),
    _cert('2', '정보처리산업기사'),
    _cert('3', '정보처리기사', qualGbCd: 'C'),
    _cert('4', '한식'),
  ];

  test('문장에 언급된 자격증을 찾는다', () {
    final Certificate? found = findMentionedCertificate(
      '정보처리 산업기사 시험이 3개월 남았어요',
      certificates,
    );
    expect(found?.id, '2');
  });

  test('이름이 같으면 국가기술자격을 고른다', () {
    final Certificate? found = findMentionedCertificate('정보처리기사 준비하려고요', [
      certificates[2],
      certificates[0],
    ]);
    expect(found?.id, '1');
  });

  test('언급이 없거나 이름이 너무 짧으면 찾지 않는다', () {
    expect(findMentionedCertificate('안녕하세요 공부하고 싶어요', certificates), isNull);
    expect(findMentionedCertificate('한식 먹고 싶다', certificates), isNull);
  });
}
