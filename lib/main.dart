import 'package:flutter/material.dart';
import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.load();
  await AppBootstrap.initialize();
  runApp(
  AppScope(
      session: AppBootstrap.userSession,
      tripRepository: AppBootstrap.tripRepository,
      child: TripApp(themeController: themeController),
    ),
  );
}
