import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TripApp());
    await tester.pump();
    // Flush trip list load + stagger animations
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Trips'), findsOneWidget);
  });
}
