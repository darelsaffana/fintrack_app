import 'package:flutter/material.dart';

/// Central color tokens — updated to a light theme with deep purple accents 
/// based on the provided reference design.
class AppColors {
  static bool isDark = false;

  static Color get bgApp => isDark ? const Color(0xFF0D1326) : const Color(0xFFF4F6FB);
  static Color get sidebar => isDark ? const Color(0xFF080C18) : const Color(0xFFFFFFFF);
  static Color get card => isDark ? const Color(0xFF131A2E) : const Color(0xFFFFFFFF);
  static Color get cardBorder => isDark ? const Color(0xFF1E2740) : const Color(0xFFE5E7EB);
  static Color get border => isDark ? const Color(0xFF1C243A) : const Color(0xFFE5E7EB);
  static Color get text => isDark ? const Color(0xFFE7EBF3) : const Color(0xFF111827);
  static Color get muted => isDark ? const Color(0xFF7D8AA8) : const Color(0xFF6B7280);
  static Color get mutedDim => isDark ? const Color(0xFF4B5773) : const Color(0xFF9CA3AF);

  static const income = Color(0xFF10B981); // Green
  static const expense = Color(0xFFF43F5E); // Red
  static const balance = Color(0xFF3B82F6); // Blue
  static const accent = Color(0xFF4A00E0); // Deep Purple
  static const accentSecondary = Color(0xFF8E24AA); // Light Purple

  static const categoryPalette = <Color>[
    Color(0xFF4A00E0),
    Color(0xFF8E24AA),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];
}

ThemeData buildAppTheme() {
  final isDark = AppColors.isDark;
  final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgApp,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.card,
      onSurface: AppColors.text,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.bgApp : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      labelStyle: TextStyle(color: AppColors.muted),
      hintStyle: TextStyle(color: AppColors.mutedDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardColor: AppColors.card,
    dividerColor: AppColors.border,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgApp,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
  );
}

/// Parses a "#RRGGBB" hex string (as stored by the API) into a [Color].
Color hexToColor(String hex) {
  var h = hex.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

String formatRupiah(num value) {
  final s = value.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buffer.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}
