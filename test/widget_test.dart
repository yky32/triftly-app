import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/app.dart';
import 'package:triftly/core/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders', (WidgetTester tester) async {
    final themeController = ThemeController();
    await themeController.load();

    await tester.pumpWidget(TripApp(themeController: themeController));
    await tester.pump();
    // Flush trip list load + stagger animations
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Trips'), findsOneWidget);
  });
}
