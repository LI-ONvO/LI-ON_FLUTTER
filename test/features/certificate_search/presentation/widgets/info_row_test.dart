import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/info_row.dart';

void main() {
  testWidgets('글자가 커져도 값이 줄바꿈되며 행이 늘어날 뿐 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, home) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(3.0)),
          child: home!,
        ),
        home: const Scaffold(
          body: CertificateInfoRow(label: '필기 응시료', value: '19,400원'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CertificateInfoRow)).height,
      greaterThan(45),
    );
  });
}
