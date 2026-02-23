import 'package:flutter/material.dart';
part 'theme_extension.dart';

final _textTheme = const TextTheme(
  displayLarge: TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
  ),
  displayMedium: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32.0,
  ),
  titleLarge: TextStyle(
    fontSize: 28.0,
  ),
  titleMedium: TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
  ),
  titleSmall: TextStyle(
    fontSize: 18.0,
  ),
  bodyLarge: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  ),
  bodyMedium: TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  ),
).apply(
  bodyColor: const Color(0xFF1D1D1D),
);

class CustomTheme {
  static ThemeData lightThemeData() {
    final textThemeLight = _textTheme.apply(
      displayColor: const Color(0xFFFFFFFF),
      bodyColor: const Color(0xFFFFFFFF),
    );
    return ThemeData.light(
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: textThemeLight.bodyLarge,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB), // Professional Blue
        secondary: Color(0xFF059669), // Parking Green
        tertiary: Color(0xFF7C3AED), // Premium Purple
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1F2937),
        surfaceContainerHighest: Color(0xFFF8FAFC),
        onSurfaceVariant: Color(0xFF6B7280),
        error: Color(0xFFDC2626),
        onError: Color(0xFFFFFFFF),
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(64, 50),
          ),
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
          color: Color(0xfff0f0f0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF909090),
        space: 0,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xFF909090),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xFF909090),
            ),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: const Color(0xFF313131),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textThemeLight.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
        unselectedLabelStyle: textThemeLight.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.0,
          color: const Color(0xFF909090),
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
        surfaceTintColor: Color(0xFFFFFFFF),
      ),
      textTheme: textThemeLight,
      extensions: [
        const CustomThemeExtension(
          highlightColor: Color(0xFF10B981),
        ),
      ],
    );
  }

  static ThemeData darkThemeData() {
    final textThemeDark = _textTheme.apply(
      displayColor: const Color(0xFFFFFFFF),
      bodyColor: const Color(0xFFFFFFFF),
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
        primary: Color(0xFF3B82F6), // Brighter Blue for dark
        secondary: Color(0xFF10B981), // Bright Green for dark
        tertiary: Color(0xFF8B5CF6), // Bright Purple for dark
        surface: Color(0xFF1F2937),
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFF374151),
        onSurfaceVariant: Color(0xFF9CA3AF),
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(64, 50),
          ),
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
          color: Color(0xffd1d1d1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF676F7B),
        space: 0,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xFF676F7B),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xFF676F7B),
            ),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: const Color(0xFF313131),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textThemeDark.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
        unselectedLabelStyle: textThemeDark.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.0,
          color: const Color(0xFF676F7B),
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
      extensions: [
        const CustomThemeExtension(
          highlightColor: Color(0xFF34D399),
        ),
      ],
    );
  }
}
