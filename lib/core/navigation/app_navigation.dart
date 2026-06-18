import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/router/app_page.dart';

/// Trip-centric navigation helpers (shell tabs vs full-screen flows).
abstract final class AppNavigation {
  /// Opens the day/spot planner (full screen, no bottom nav).
  static void openTripPlanner(BuildContext context) {
    context.push(AppPage.routine.path);
  }

  static void openTripsTab(BuildContext context) {
    context.go(AppPage.trips.path);
  }

  static void openTodayTab(BuildContext context) {
    context.go(AppPage.today.path);
  }

  static void openSpendTab(BuildContext context) {
    context.go(AppPage.spend.path);
  }
}
