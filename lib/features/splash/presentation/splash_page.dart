import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_page.dart';
import '../../../core/navigation/share_deep_link_bridge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Branded splash — logo holds briefly, fades out, then opens Trips (Plan tab).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const lottieAsset = 'assets/lottie/splash-logo.json';
  static const holdDuration = Duration(milliseconds: 900);
  static const fadeDuration = Duration(milliseconds: 650);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: SplashPage.fadeDuration);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(SplashPage.holdDuration);
    if (!mounted) return;
    await _fadeController.forward();
    if (!mounted) return;
    _goToTrips();
  }

  void _goToTrips() {
    if (_navigated) return;
    _navigated = true;
    final shareToken = ShareDeepLinkBridge.consumePendingShareToken();
    if (shareToken != null) {
      context.go('/s/$shareToken');
      return;
    }
    context.go(AppPage.plan.path);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDimDark : AppColors.accentSurface,
      body: SafeArea(
        child: FadeTransition(
          opacity: ReverseAnimation(_fadeAnimation),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Lottie.asset(
                      SplashPage.lottieAsset,
                      fit: BoxFit.contain,
                      repeat: false,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.flight_takeoff_rounded,
                        size: 96,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Triftly',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Explore · Plan · Spend',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
