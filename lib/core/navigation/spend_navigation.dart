import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_page.dart';

/// Navigation between global Spend page and trip Spend tab.
abstract final class SpendNavigation {
  static const globalSpendPath = '/spend';

  static void openGlobalSpend(BuildContext context) {
    context.go(globalSpendPath);
  }

  static void openTripSpend(BuildContext context, String tripId) {
    context.go('${AppPage.plan.path}/$tripId?tab=spend');
  }
}
