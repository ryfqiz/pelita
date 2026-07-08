// ============================================================
//  PELITA · lib/core/theme.dart
//  Color palette and ThemeData configuration
// ============================================================

import 'package:flutter/material.dart';

class PelitaTheme {
  static const Color background = Color(0xFFFCF6EA);
  static const Color darkTeal = Color(0xFF123C3A);
  static const Color orangeHighlight = Color(0xFFF5A623);
  static const Color softYellow = Color(0xFFFCD98A);
  static const Color sageGreen = Color(0xFF7FB69B);
  static const Color coralRed = Color(0xFFF16A50);
  static const Color honeyTint = Color(0xFFFFF3DC);
  static const Color textDark = Color(0xFF1C2C2B);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkTeal,
          surface: background,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}
