import 'package:flutter/material.dart';
import 'core/bootstrap/app_bloc_providers.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/share_deep_link_bridge.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class TripApp extends StatefulWidget {
  const TripApp({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  State<TripApp> createState() => _TripAppState();
}

class _TripAppState extends State<TripApp> {
  @override
  void initState() {
    super.initState();
    ShareDeepLinkBridge.install(appRouter);
  }

  @override
  void dispose() {
    ShareDeepLinkBridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: widget.themeController,
      child: ListenableBuilder(
        listenable: widget.themeController,
        builder: (context, _) {
          return AppBlocProviders(
            child: MaterialApp.router(
              title: 'Triftly',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: widget.themeController.themeMode,
              routerConfig: appRouter,
            ),
          );
        },
      ),
    );
  }
}
