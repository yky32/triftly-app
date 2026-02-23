import 'package:flutter/material.dart';

/// App pages and routes. navBarMemberIndex 99 = not in bottom nav (standalone).
enum AppPage {
  login('Login', '/login', Icons.login, 99),
  home('Home', '/home', Icons.home, 0),
  explore('Explore', '/explore', Icons.explore, 1),
  activity('Activity', '/activity', Icons.dashboard, 2),
  settings('Settings', '/settings', Icons.settings, 3);

  const AppPage(this.name, this.path, this.icon, this.navBarMemberIndex);

  final String name;
  final String path;
  final IconData icon;
  final int navBarMemberIndex;
}
