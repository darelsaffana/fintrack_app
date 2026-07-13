import 'package:flutter/material.dart';

/// Central color tokens — mirrors the dark navy Fintrack palette used
/// across dashboard cards, sidebar, and charts.
class AppColors {
  static const bgApp = Color(0xFF0D1326);
  static const sidebar = Color(0xFF080C18);
  static const card = Color(0xFF131A2E);
  static const cardBorder = Color(0xFF1E2740);
  static const border = Color(0xFF1C243A);
  static const text = Color(0xFFE7EBF3);
  static const muted = Color(0xFF7D8AA8);
  static const mutedDim = Color(0xFF4B5773);

  static const income = Color(0xFF3DDC97);
  static const expense = Color(0xFFFF6B8A);
  static const balance = Color(0xFF4FC3F7);
  static const accent = Color(0xFF8B7CF6);

  static const categoryPalette = <Color>[
    Color(0xFF3DDC97),
    Color(0xFF4FC3F7),
    Color(0xFF8B7CF6),
    Color(0xFFFF6B8A),
    Color(0xFFFFB84F),
    Color(0xFF4FD1C5),
    Color(0xFFF472B6),
    Color(0xFFFACC15),
  ];
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgApp,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.card,
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
