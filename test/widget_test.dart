import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TripApp());
    expect(find.text('Explore'), findsOneWidget);
  });
}
