import 'package:flutter/material.dart';

class AppTheme {
  static const String _font = 'Poppins';

  static final ThemeData light = _build(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFFB5532A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFB5532A),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFDCC8),
      onPrimaryContainer: const Color(0xFF4A1A06),
      secondary: const Color(0xFF5B3A29),
      onSecondary: Colors.white,
      tertiary: const Color(0xFFE0A458),
      surface: const Color(0xFFFFF8EE),
      onSurface: const Color(0xFF3B2A20),
      surfaceContainerLow: Colors.white,
      surfaceContainerHighest: const Color(0xFFF3E4D2),
      outlineVariant: const Color(0xFFE2CDB6),
    ),
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFFB5532A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFE8A06B),
      onPrimary: const Color(0xFF3B1F0E),
      primaryContainer: const Color(0xFF6B3318),
      onPrimaryContainer: const Color(0xFFFFDCC8),
      secondary: const Color(0xFFD9B79B),
      onSecondary: const Color(0xFF2B1B10),
      tertiary: const Color(0xFFE0A458),
      surface: const Color(0xFF1F1612),
      onSurface: const Color(0xFFF5E9DC),
      surfaceContainerLow: const Color(0xFF2B201A),
      surfaceContainerHighest: const Color(0xFF3A2C24),
      outlineVariant: const Color(0xFF55443A),
    ),
  );

  static ThemeData _build(ColorScheme s) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const label = TextStyle(fontFamily: _font, fontWeight: FontWeight.bold);

    return ThemeData(
      useMaterial3: true,
      fontFamily: _font,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: s.surface,
        foregroundColor: s.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: s.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: shape,
          textStyle: label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: shape,
          side: BorderSide(color: s.outlineVariant),
          textStyle: label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: label),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: s.secondary,
        contentTextStyle: TextStyle(fontFamily: _font, color: s.onSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}