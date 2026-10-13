import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';

void main() {
  group('Certificate', () {
    test('목록 응답의 qualGbCd를 읽는다', () {
      final Certificate certificate = Certificate.fromJson({
        'jmCd': '7910',
        'name': '프로그래밍기능사',
        'category': '기능사',
        'qualGbCd': 'C',
      });

      expect(certificate.qualGbCd, 'C');
    });

    test('서버가 qualGbCd를 안 내려주면 빈 값으로 받는다', () {
      final Certificate certificate = Certificate.fromJson({
        'jmCd': '7910',
        'name': '프로그래밍기능사',
        'category': null,
      });

      expect(certificate.qualGbCd, '');
      expect(certificate.subtitle, '');
    });

    test('같은 이름이라도 자격구분으로 부제가 갈린다', () {
      const Certificate national = Certificate(
        id: '1',
        name: '프로그래밍기능사',
        category: '기능사',
        qualGbCd: 'T',
      );
      const Certificate process = Certificate(
        id: '1',
        name: '프로그래밍기능사',
        category: '기능사',
        qualGbCd: 'C',
      );

      expect(national.subtitle, '기능사 · 국가기술자격');
      expect(process.subtitle, '기능사 · 과정평가형자격');
    });

    test('분류가 없는 과정평가형은 자격구분만 부제로 쓴다', () {
      const Certificate certificate = Certificate(
        id: '1',
        name: '프로그래밍기능사',
        category: '',
        qualGbCd: 'C',
      );

      expect(certificate.subtitle, '과정평가형자격');
    });
  });

  test('qualGbLabel은 T·S·W·C를 한글로 바꾸고 모르는 코드는 비운다', () {
    expect(qualGbLabel('T'), '국가기술자격');
    expect(qualGbLabel('S'), '국가전문자격');
    expect(qualGbLabel('W'), '일학습병행자격');
    expect(qualGbLabel('C'), '과정평가형자격');
    expect(qualGbLabel('X'), '');
    expect(qualGbLabel(''), '');
  });

  test('상세 응답의 qualGbCd를 읽고, 없으면 빈 값이다', () {
    final CertificateDetail withCode = CertificateDetail.fromJson({
      'jmCd': '7910',
      'name': '프로그래밍기능사',
      'category': null,
      'qualGbCd': 'C',
    });
    final CertificateDetail withoutCode = CertificateDetail.fromJson({
      'jmCd': '7910',
      'name': '프로그래밍기능사',
    });

    expect(withCode.qualGbCd, 'C');
    expect(withoutCode.qualGbCd, '');
  });

  group('ExamSchedule', () {
    test('필기·실기 일정이 null이어도 파싱된다', () {
      final CertificateDetail detail = CertificateDetail.fromJson({
        'jmCd': '7910',
        'name': '프로그래밍기능사',
        'examSchedules': [
          {
            'implYy': 2026,
            'implSeq': '1',
            'docRegStartDt': null,
            'docRegEndDt': null,
            'docExamStartDt': null,
            'docExamEndDt': null,
            'docPassDt': null,
            'pracRegStartDt': '2026-05-01',
            'pracRegEndDt': '2026-05-05',
            'pracExamStartDt': '2026-06-01',
            'pracExamEndDt': '2026-06-10',
            'pracPassDt': '2026-07-01',
          },
        ],
      });

      final ExamSchedule schedule = detail.examSchedules.single;
      expect(schedule.implSeq, 1);
      expect(schedule.docRegStartDt, isNull);
      expect(schedule.docPassDt, isNull);
      expect(schedule.pracRegStartDt, DateTime.parse('2026-05-01'));
    });

    test('일정 키가 아예 없어도 파싱된다', () {
      final ExamSchedule schedule = ExamSchedule.fromJson({
        'implYy': 2026,
        'implSeq': 2,
      });

      expect(schedule.docRegStartDt, isNull);
      expect(schedule.pracPassDt, isNull);
    });
  });
}
