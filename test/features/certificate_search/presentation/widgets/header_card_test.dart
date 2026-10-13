import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/header_card.dart';

void main() {
  Future<void> pumpHeader(WidgetTester tester, CertificateDetail detail) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CertificateHeaderCard(detail: detail)),
      ),
    );
  }

  testWidgets('분류와 자격구분을 배지로 함께 보여준다', (tester) async {
    await pumpHeader(
      tester,
      const CertificateDetail(
        id: '7910',
        name: '프로그래밍기능사',
        category: '기능사',
        qualGbCd: 'T',
      ),
    );

    expect(find.text('기능사'), findsOneWidget);
    expect(find.text('국가기술자격'), findsOneWidget);
  });

  testWidgets('분류가 없는 과정평가형은 자격구분 배지만 보여준다', (tester) async {
    await pumpHeader(
      tester,
      const CertificateDetail(
        id: '7910',
        name: '프로그래밍기능사',
        category: '',
        qualGbCd: 'C',
      ),
    );

    expect(find.text('과정평가형자격'), findsOneWidget);
  });
}
