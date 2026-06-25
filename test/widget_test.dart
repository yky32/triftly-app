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
        session: AppBootstrap.userSession,
        tripRepository: AppBootstrap.tripRepository,
        child: TripApp(themeController: themeController),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Trips'), findsOneWidget);
  });
}
