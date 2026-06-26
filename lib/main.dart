import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/bootstrap/bootstrap_error_app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    developer.log(
      details.exceptionAsString(),
      name: 'triftly.flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      '$error',
      name: 'triftly.platform',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  final themeController = ThemeController();
  Object? bootstrapError;
  StackTrace? bootstrapStack;

  try {
    await themeController.load();
    await AppBootstrap.initialize();
  } catch (error, stack) {
    bootstrapError = error;
    bootstrapStack = stack;
    developer.log(
      'Startup failed',
      name: 'triftly.bootstrap',
      error: error,
      stackTrace: stack,
    );
  }

  runApp(
    bootstrapError != null
        ? BootstrapErrorApp(error: bootstrapError, stackTrace: bootstrapStack)
        : AppScope(
            session: AppBootstrap.userSession,
            tripRepository: AppBootstrap.tripRepository,
            child: TripApp(themeController: themeController),
          ),
  );
}
