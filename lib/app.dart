import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/bootstrap/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/navigation/app_router.dart';
import 'features/3_spend/bloc/spend_overview_bloc.dart';

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
          return ListenableBuilder(
            listenable: AppBootstrap.userSession,
            builder: (context, _) {
              return BlocProvider(
                create: (_) => AppScopeBlocs.createSpendOverviewBloc()
                  ..add(const SpendOverviewLoadRequested()),
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
          );
        },
      ),
    );
  }
}
