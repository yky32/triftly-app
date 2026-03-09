// Basic Flutter widget smoke test for Triftly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:triftly/main.dart';
import 'package:triftly/core/theme/theme_preference.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';

void main() {
  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themePreference = ThemePreference(prefs);
    final routineRepository = RoutineRepository(prefs);

    await tester.pumpWidget(MyApp(
      themePreference: themePreference,
      routineRepository: routineRepository,
    ));

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
