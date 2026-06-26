import 'package:flutter/material.dart';
import 'core/bootstrap/app_bloc_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/navigation/app_router.dart';

class TripApp extends StatelessWidget {
  const TripApp({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return AppBlocProviders(
            child: MaterialApp.router(
              title: 'Triftly',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeController.themeMode,
              routerConfig: appRouter,
            ),
          );
        },
      ),
    );
  }
}
