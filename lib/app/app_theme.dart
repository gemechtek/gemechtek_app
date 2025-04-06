import 'package:flutter/material.dart';

class AppTheme {
  // Main colors from the image
  static const Color primaryBlue = Color(0xFF0089FF);
  static const Color textDark = Color(0xFF232323);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color starColor = Color(0xFFDDDDDD);

  // Additional complementary colors
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF66B8FF);
  static const Color secondaryText = Color(0xFF666666);

  // Text style with DM Sans font
  static const String fontFamily = 'DM Sans';

  // Theme data
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          onPrimary: Colors.white,
          primaryContainer: primaryLight,
          onPrimaryContainer: primaryDark,
          secondary: primaryDark,
          onSecondary: Colors.white,
          surface: backgroundColor,
          onSurface: textDark,
          surfaceContainerHighest: lightGray,
          onSurfaceVariant: secondaryText,
        ),

        // Text themes with DM Sans font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: fontFamily, color: textDark),
          displayMedium: TextStyle(fontFamily: fontFamily, color: textDark),
          displaySmall: TextStyle(fontFamily: fontFamily, color: textDark),
          headlineLarge: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.w600),
          titleSmall: TextStyle(
              fontFamily: fontFamily,
              color: textDark,
              fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: fontFamily, color: textDark),
          bodyMedium: TextStyle(fontFamily: fontFamily, color: textDark),
          bodySmall: TextStyle(fontFamily: fontFamily, color: secondaryText),
          labelLarge: TextStyle(fontFamily: fontFamily, color: textDark),
          labelMedium: TextStyle(fontFamily: fontFamily, color: secondaryText),
          labelSmall: TextStyle(fontFamily: fontFamily, color: secondaryText),
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: const BorderSide(color: primaryBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          fillColor: lightGray,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          hintStyle: const TextStyle(
            fontFamily: fontFamily,
            color: secondaryText,
          ),
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            color: textDark,
          ),
        ),

        // Card theme
        cardTheme: CardTheme(
          color: backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // App Bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: backgroundColor,
          selectedItemColor: primaryBlue,
          unselectedItemColor: secondaryText,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),

        // Scaffold background color
        scaffoldBackgroundColor: backgroundColor,

        // Divider theme
        dividerTheme: const DividerThemeData(
          color: mediumGray,
          thickness: 1,
        ),

        // Checkbox theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }
            return Colors.transparent;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: mediumGray),
        ),

        // Radio button theme
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }
            return secondaryText;
          }),
        ),

        // Switch theme
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }
            return Colors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryLight;
            }
            return mediumGray;
          }),
        ),
      );
}
