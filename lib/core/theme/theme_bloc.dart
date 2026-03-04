import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/theme/theme_preference.dart';

part 'theme_event.dart';

/// Manages app theme mode (light/dark). UI is designed for light mode first.
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(this._preference) : super(_preference.themeMode) {
    on<ThemeModeRequested>(_handleThemeModeRequested);
  }

  final ThemePreference _preference;

  Future<void> _handleThemeModeRequested(
    ThemeModeRequested event,
    Emitter<ThemeMode> emit,
  ) async {
    await _preference.setThemeMode(event.mode);
    emit(event.mode);
  }
}
