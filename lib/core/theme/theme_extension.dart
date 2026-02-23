part of 'theme.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  const CustomThemeExtension({
    required this.highlightColor,
  });

  final Color highlightColor;

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? highlightColor,
  }) {
    return CustomThemeExtension(
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  @override
  CustomThemeExtension lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
    );
  }
}
