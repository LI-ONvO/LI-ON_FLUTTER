import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: home)));
}

bool isElevatedButtonEnabled(WidgetTester tester) {
  final ElevatedButton button = tester.widget<ElevatedButton>(
    find.byType(ElevatedButton),
  );
  return button.onPressed != null;
}
