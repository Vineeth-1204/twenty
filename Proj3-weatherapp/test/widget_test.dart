import 'package:flutter_test/flutter_test.dart';
import 'package:dune_weather_app/main.dart';

void main() {
  testWidgets('Dune weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DuneWeatherApp());
    expect(find.textContaining('D U N E'), findsOneWidget);
  });
}
