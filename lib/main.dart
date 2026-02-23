import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/environment.dart';
import 'package:triftly/core/localization/app_localizations.dart';
import 'package:triftly/core/theme/theme.dart';
import 'package:triftly/features/login/bloc/login_bloc.dart';
import 'package:triftly/router/app_router.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Environment.load();
    } catch (e, st) {
      debugPrint('Environment.load failed: $e\n$st');
    }

    FlutterError.onError = (details) {
      debugPrint('FlutterError: ${details.exception}\n${details.stack}');
      FlutterError.presentError(details);
    };

    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Zone error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Triftly',
        theme: CustomTheme.lightThemeData(),
        darkTheme: CustomTheme.darkThemeData(),
        themeMode: ThemeMode.system,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.router,
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          FormBuilderLocalizations.delegate,
        ],
      ),
    );
  }
}
