import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/app.dart';
import 'package:triftly/core/bootstrap/app_bootstrap.dart';
import 'package:triftly/core/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '.',
    );
    await AppBootstrap.initialize();
  });

  testWidgets('App renders', (WidgetTester tester) async {
    final themeController = ThemeController();
    await themeController.load();

    await tester.pumpWidget(
      AppScope(
        tripRepository: AppBootstrap.tripRepository,
        child: TripApp(themeController: themeController),
      ),
    );
    await tester.pump();
    expect(find.text('Triftly'), findsOneWidget);

    // Splash hold + fade, then navigate to Trips.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);
  });
}
