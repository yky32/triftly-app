import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/bootstrap/bootstrap_error_app.dart';
import 'core/bootstrap/flutter_dev_error_filters.dart';
import 'core/environment.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.load();

  FlutterError.onError = (details) {
    if (isKnownSimulatorKeyboardSyncNoise(details.exception)) {
      return;
    }
    developer.log(
      details.exceptionAsString(),
      name: 'triftly.flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (isKnownSimulatorKeyboardSyncNoise(error)) {
      return true;
    }
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
