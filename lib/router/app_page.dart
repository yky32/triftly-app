import 'package:flutter/material.dart';

/// App pages and routes. navBarMemberIndex 99 = not in bottom nav (standalone).
enum AppPage {
  login('Login', '/login', Icons.login, 99),
  today('Today', '/today', Icons.today, 0),
  trips('My Trips', '/trips', Icons.luggage, 1),
  routine('Routine', '/routine', Icons.schedule, 2),
  map('Map', '/map', Icons.map, 3),
  spend('Spend', '/spend', Icons.account_balance_wallet, 4),
  settings('Settings', '/settings', Icons.settings, 99);

  const AppPage(this.name, this.path, this.icon, this.navBarMemberIndex);

  final String name;
  final String path;
  final IconData icon;
  final int navBarMemberIndex;
}
