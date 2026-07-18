import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color + theme definitions.
/// Green = price up, Red = price down, kept consistent across light/dark.
class AppColors {
  static const priceUp = Color(0xFF16C784);
  static const priceDown = Color(0xFFEA3943);
  static const neutral = Color(0xFF8A8F98);

  static const brandPrimary = Color(0xFF2F6FED);
  static const brandAccent = Color(0xFFFFB020);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFFF6F7FB),
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerColor: const Color(0xFFE7E9F0),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1116),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF0E1116),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF171B22),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerColor: const Color(0xFF262B33),
    );
  }
}

/// Simple theme-mode holder so any screen can toggle dark/light.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
