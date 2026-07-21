import 'package:flutter/material.dart';

/// Light Mode Color Tokens
class LightColors {
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF7974EC,
    <int, Color>{
      50: Color(0xFFF2F1FD),
      100: Color(0xFFDFDDFA),
      200: Color(0xFFC9C7F6),
      300: Color(0xFFB3B0F2),
      400: Color(0xFFA19DF0),
      500: Color(0xFF7974EC), // Base Logo Color
      600: Color(0xFF6E69DF),
      700: Color(0xFF605CCF),
      800: Color(0xFF5350C0),
      900: Color(0xFF3C39A6),
    },
  );
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
  static const accent = Color(0xFF7974EC); // Soft Indigo (Logo Color)
  static const accentSecondary = Color(0xFF605CCF); // Shade 700

  static const categoryPalette = <Color>[
    Color(0xFF7974EC),
    Color(0xFF8E24AA),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];
}

/// Dark Mode Color Tokens
class DarkColors {
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF7974EC,
    <int, Color>{
      50: Color(0xFFF2F1FD),
      100: Color(0xFFDFDDFA),
      200: Color(0xFFC9C7F6),
      300: Color(0xFFB3B0F2),
      400: Color(0xFFA19DF0),
      500: Color(0xFF7974EC), // Base Logo Color
      600: Color(0xFF6E69DF),
      700: Color(0xFF605CCF),
      800: Color(0xFF5350C0),
      900: Color(0xFF3C39A6),
    },
  );
  static const bgApp = Color(0xFF0F111A); // Very dark blue background
  static const sidebar = Color(0xFF161824);
  static const card = Color(0xFF1E2030);
  static const cardBorder = Color(0xFF33364D);
  static const border = Color(0xFF33364D);
  static const text = Color(0xFFE5E7EB); // Light gray for contrast
  static const muted = Color(0xFF9CA3AF);
  static const mutedDim = Color(0xFF6B7280);

  static const income = Color(0xFF10B981); // Green
  static const expense = Color(0xFFF43F5E); // Red
  static const balance = Color(0xFF3B82F6); // Blue
  static const accent = Color(0xFF7974EC); // Soft Indigo (Logo Color)
  static const accentSecondary = Color(0xFF605CCF); // Shade 700

  static const categoryPalette = <Color>[
    Color(0xFF7974EC),
    Color(0xFF8E24AA),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];
}

/// Helper to get colors based on current brightness
class AppColors {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static MaterialColor primarySwatch(BuildContext context) =>
      isDark(context) ? DarkColors.primarySwatch : LightColors.primarySwatch;
  static Color bgApp(BuildContext context) =>
      isDark(context) ? DarkColors.bgApp : LightColors.bgApp;
  static Color sidebar(BuildContext context) =>
      isDark(context) ? DarkColors.sidebar : LightColors.sidebar;
  static Color card(BuildContext context) =>
      isDark(context) ? DarkColors.card : LightColors.card;
  static Color cardBorder(BuildContext context) =>
      isDark(context) ? DarkColors.cardBorder : LightColors.cardBorder;
  static Color border(BuildContext context) =>
      isDark(context) ? DarkColors.border : LightColors.border;
  static Color text(BuildContext context) =>
      isDark(context) ? DarkColors.text : LightColors.text;
  static Color muted(BuildContext context) =>
      isDark(context) ? DarkColors.muted : LightColors.muted;
  static Color mutedDim(BuildContext context) =>
      isDark(context) ? DarkColors.mutedDim : LightColors.mutedDim;

  static Color income(BuildContext context) =>
      isDark(context) ? DarkColors.income : LightColors.income;
  static Color expense(BuildContext context) =>
      isDark(context) ? DarkColors.expense : LightColors.expense;
  static Color balance(BuildContext context) =>
      isDark(context) ? DarkColors.balance : LightColors.balance;
  static Color accent(BuildContext context) =>
      isDark(context) ? DarkColors.accent : LightColors.accent;
  static Color accentSecondary(BuildContext context) => isDark(context)
      ? DarkColors.accentSecondary
      : LightColors.accentSecondary;

  static List<Color> categoryPalette(BuildContext context) => isDark(context)
      ? DarkColors.categoryPalette
      : LightColors.categoryPalette;
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: LightColors.bgApp,
    colorScheme: base.colorScheme.copyWith(
      primary: LightColors.accent,
      surface: LightColors.card,
      onSurface: LightColors.text,
      brightness: Brightness.light,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: LightColors.text,
      displayColor: LightColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColors.bgApp,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.accent),
      ),
      labelStyle: const TextStyle(color: LightColors.muted),
      hintStyle: const TextStyle(color: LightColors.mutedDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardColor: LightColors.card,
    dividerColor: LightColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.bgApp,
      foregroundColor: LightColors.text,
      elevation: 0,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: DarkColors.bgApp,
    colorScheme: base.colorScheme.copyWith(
      primary: DarkColors.accent,
      surface: DarkColors.card,
      onSurface: DarkColors.text,
      brightness: Brightness.dark,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: DarkColors.text,
      displayColor: DarkColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.bgApp,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: DarkColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: DarkColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: DarkColors.accent),
      ),
      labelStyle: TextStyle(color: DarkColors.muted),
      hintStyle: TextStyle(color: DarkColors.mutedDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardColor: DarkColors.card,
    dividerColor: DarkColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.bgApp,
      foregroundColor: DarkColors.text,
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
