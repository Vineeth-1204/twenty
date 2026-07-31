import 'package:flutter_test/flutter_test.dart';
import 'package:memocho_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(MemochoApp, isNotNull);
  });
}
