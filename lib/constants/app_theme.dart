
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7653B5);
  static const Color secondaryColor = Color(0xFF8E72C7);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color blueAccent = Color(0xFFDCEBFF);
  static const Color paleYellow = Color(0xFFFFF2BF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      fontFamily: 'Roboto',
    );
  }
}
