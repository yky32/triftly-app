import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:triftly/core/constants/app_config.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/services/share_receiver_service.dart';

/// Simple splash screen. If app was opened via Share → Triftly (e.g. from Google Maps), goes to map with that location; otherwise to the default page after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    final sharedLoc = await ShareReceiverService.getPendingSharedLocation();
    if (sharedLoc != null && mounted) {
      if (AppConfig.isPageEnabled(AppPage.map)) {
        context.go(AppPage.map.path, extra: sharedLoc);
      } else {
        context.go(AppConfig.defaultPage.path);
      }
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    context.go(AppConfig.defaultPage.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/splash-logo.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 10),
            Text(
              'Triftly',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
