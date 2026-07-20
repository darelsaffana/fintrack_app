import 'package:flutter/material.dart';

/// Central color tokens — updated to a light theme with deep purple accents 
/// based on the provided reference design.
class AppColors {
  static const bgApp = Color(0xFFF4F6FB); // Very light greyish blue background
  static const sidebar = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE5E7EB);
  static const border = Color(0xFFE5E7EB);
  static const text = Color(0xFF111827); // Very dark gray for contrast
  static const muted = Color(0xFF6B7280);
  static const mutedDim = Color(0xFF9CA3AF);

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
  final base = ThemeData.light(useMaterial3: true);
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
      fillColor: AppColors.bgApp,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.mutedDim),
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
    appBarTheme: const AppBarTheme(
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
