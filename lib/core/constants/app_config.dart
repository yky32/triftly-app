import 'package:triftly/router/app_page.dart';

/// Centralized app configuration for enabling/disabling features.
///
/// Modify the [enabledPages] set to control which pages appear in the app.
/// Pages not in this set will be:
/// - Hidden from the bottom navigation bar
/// - Not accessible via routing
/// - Redirected to the default page if navigated to
class AppConfig {
  AppConfig._();

  /// Pages that are enabled in the app.
///
  /// Remove a page from this set to disable it throughout the app.
  /// Example: To disable 'Today', remove `AppPage.today` from this set.
  static const Set<AppPage> enabledPages = {
    // AppPage.today,  // Disabled - uncomment to enable
    AppPage.trips,
    AppPage.routine,
    AppPage.map,
    AppPage.spend,
    AppPage.login,
    AppPage.settings,
  };

  /// The default page to navigate to when the app starts or when
  /// navigating to a disabled page.
  ///
  /// This should be one of the enabled pages with navBarMemberIndex != 99.
  static const AppPage defaultPage = AppPage.trips;

  /// The login page (standalone, always enabled for auth flow).
  static const AppPage loginPage = AppPage.login;

  /// Check if a page is enabled.
  static bool isPageEnabled(AppPage page) => enabledPages.contains(page);

  /// Get all enabled navigation bar pages (sorted by navBarMemberIndex).
  static List<AppPage> get enabledNavPages {
    final pages = enabledPages
        .where((p) => p.navBarMemberIndex != 99)
        .toList()
      ..sort((a, b) => a.navBarMemberIndex.compareTo(b.navBarMemberIndex));
    return pages;
  }

  /// Get the first enabled nav page (useful for default redirects).
  static AppPage get firstEnabledNavPage {
    final pages = enabledNavPages;
    return pages.isNotEmpty ? pages.first : defaultPage;
  }
}
