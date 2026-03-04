// Basic Flutter widget smoke test for Triftly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:triftly/main.dart';
import 'package:triftly/core/theme/theme_preference.dart';

void main() {
  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themePreference = ThemePreference(prefs);

    await tester.pumpWidget(MyApp(themePreference: themePreference));

    expect(find.byType(MaterialApp), findsOneWidget);

    // Let splash delay complete so no pending timers when test ends
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
