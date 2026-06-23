import 'package:flutter/material.dart';
import 'app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.load();
  // TODO: Initialize Supabase
  // TODO: Initialize Hive
  runApp(TripApp(themeController: themeController));
}
