import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/features/login/bloc/login_bloc.dart';
import 'package:sample_app/router/app_page.dart';

/// Skeleton settings page. Sign In / Sign Out only.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is LoginSuccess) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Signed in'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _handleLogout(context),
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            }
            return ElevatedButton(
              onPressed: () => context.go(AppPage.login.path),
              child: const Text('Sign In'),
            );
          },
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<LoginBloc>().add(LogoutRequest());
              context.go(AppPage.login.path);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
