import 'package:triftly/router/app_page.dart';

/// Centralized app configuration for enabling/disabling features.
///
/// Bottom nav is intentionally minimal: **Today → Trips → Spend**.
/// Trip planning (`/trips/plan`) and map are full-screen overlays.
class AppConfig {
  AppConfig._();

  static const Set<AppPage> enabledPages = {
    AppPage.today,
    AppPage.trips,
    AppPage.routine,
    // AppPage.map,
    AppPage.spend,
    AppPage.login,
    AppPage.settings,
  };

  /// Default tab after splash — in-trip companion when travelling.
  static const AppPage defaultPage = AppPage.today;

  static const AppPage loginPage = AppPage.login;

  static bool isPageEnabled(AppPage page) => enabledPages.contains(page);

  static List<AppPage> get enabledNavPages {
    final pages = enabledPages
        .where((p) => p.navBarMemberIndex != 99)
        .toList()
      ..sort((a, b) => a.navBarMemberIndex.compareTo(b.navBarMemberIndex));
    return pages;
  }

  static AppPage get firstEnabledNavPage {
    final pages = enabledNavPages;
    return pages.isNotEmpty ? pages.first : defaultPage;
  }
}
