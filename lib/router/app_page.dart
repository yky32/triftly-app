import 'package:flutter/material.dart';

/// App pages and routes.
///
/// [navBarMemberIndex] 0–2 = bottom nav (Today, Trips, Spend).
/// 99 = full-screen or standalone (planner, map, login, settings).
enum AppPage {
  login('Login', '/login', Icons.login_rounded, 99),
  today('Day', '/today', Icons.view_timeline_rounded, 0),
  trips('Plan', '/trips', Icons.edit_note_rounded, 1),
  routine('Plan trip', '/trips/plan', Icons.edit_calendar_outlined, 99),
  map('Map', '/map', Icons.map_outlined, 99),
  spend('Spend', '/spend', Icons.account_balance_wallet_outlined, 2),
  settings('Settings', '/settings', Icons.settings_outlined, 99);

  const AppPage(this.name, this.path, this.icon, this.navBarMemberIndex);

  final String name;
  final String path;
  final IconData icon;
  final int navBarMemberIndex;
}
