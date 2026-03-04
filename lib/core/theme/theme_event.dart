part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ThemeModeRequested extends ThemeEvent {
  final ThemeMode mode;

  ThemeModeRequested(this.mode);
}
