import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

class TripApp extends StatelessWidget {
  const TripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Triftly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
