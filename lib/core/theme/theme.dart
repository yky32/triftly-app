import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';
part 'theme_extension.dart';

/// Typography: Display (headings) = Satoshi Bold, Body = Satoshi Regular (design_summary).
const String _fontFamily = 'Satoshi';

final TextTheme _textTheme = const TextTheme(
  displayLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
  ),
  displayMedium: TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 32.0,
  ),
  titleLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
  ),
  titleMedium: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
  ),
  titleSmall: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  ),
  bodyMedium: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  ),
  labelLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  ),
  headlineSmall: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  ),
);

class CustomTheme {
  static ThemeData lightThemeData() {
    final textThemeLight = _textTheme.apply(
      displayColor: AppColors.onSurface,
      bodyColor: AppColors.onSurface,
    );
    return ThemeData.light(
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: AppColors.cloudWhite,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: textThemeLight.bodyLarge?.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.driftTeal,
        onPrimary: Colors.white,
        secondary: AppColors.calmGreen,
        onSecondary: Colors.white,
        tertiary: AppColors.softAmber,
        surface: AppColors.cloudWhite,
        onSurface: AppColors.slate,
        surfaceContainerHighest: AppColors.fogGray,
        onSurfaceVariant: AppColors.mistGray,
        error: AppColors.mutedRed,
        onError: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.driftTeal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 50)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: textThemeLight.bodySmall?.copyWith(
          color: AppColors.mistGray,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.fogGray,
        space: 0,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.driftTeal,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textThemeLight.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        unselectedLabelStyle: textThemeLight.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.mistGray,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: AppColors.cloudWhite,
      ),
      textTheme: textThemeLight,
      extensions: const [
        CustomThemeExtension(highlightColor: AppColors.calmGreen),
      ],
    );
  }

  static ThemeData darkThemeData() {
    final textThemeDark = _textTheme.apply(
      displayColor: AppColors.cloudWhite,
      bodyColor: AppColors.cloudWhite,
    );
    return ThemeData.dark(
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1F24),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: textThemeDark.bodyLarge,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.driftTeal,
        onPrimary: Colors.black87,
        secondary: AppColors.calmGreen,
        tertiary: AppColors.softAmber,
        surface: Color(0xFF1F2937),
        onSurface: AppColors.cloudWhite,
        surfaceContainerHighest: Color(0xFF374151),
        onSurfaceVariant: AppColors.mistGray,
        error: AppColors.mutedRed,
        onError: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.driftTeal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 50)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: textThemeDark.bodyMedium?.copyWith(
          color: AppColors.mistGray,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF676F7B),
        space: 0,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.driftTeal,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textThemeDark.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: textThemeDark.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.mistGray,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Color(0xFF1A1F24),
      ),
      textTheme: textThemeDark,
      extensions: const [
        CustomThemeExtension(highlightColor: AppColors.calmGreen),
      ],
    );
  }
}
