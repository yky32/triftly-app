import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/3_spend/bloc/spend_overview_bloc.dart';
import 'app_bootstrap.dart';
import 'app_scope.dart';

/// Root BLoC providers for app-wide presentation state.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: AppBootstrap.sessionBloc),
        BlocProvider.value(value: AppBootstrap.cloudSyncBloc),
        BlocProvider(
          create: (_) => AppScopeBlocs.createSpendOverviewBloc()
            ..add(const SpendOverviewLoadRequested()),
        ),
      ],
      child: child,
    );
  }
}
