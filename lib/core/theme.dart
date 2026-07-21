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

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final MaterialColor primarySwatch;
  final Color bgApp;
  final Color sidebar;
  final Color card;
  final Color cardBorder;
  final Color border;
  final Color text;
  final Color muted;
  final Color mutedDim;
  final Color income;
  final Color expense;
  final Color balance;
  final Color accent;
  final Color accentSecondary;
  final List<Color> categoryPalette;

  const AppColorsExtension({
    required this.primarySwatch,
    required this.bgApp,
    required this.sidebar,
    required this.card,
    required this.cardBorder,
    required this.border,
    required this.text,
    required this.muted,
    required this.mutedDim,
    required this.income,
    required this.expense,
    required this.balance,
    required this.accent,
    required this.accentSecondary,
    required this.categoryPalette,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    MaterialColor? primarySwatch,
    Color? bgApp,
    Color? sidebar,
    Color? card,
    Color? cardBorder,
    Color? border,
    Color? text,
    Color? muted,
    Color? mutedDim,
    Color? income,
    Color? expense,
    Color? balance,
    Color? accent,
    Color? accentSecondary,
    List<Color>? categoryPalette,
  }) {
    return AppColorsExtension(
      primarySwatch: primarySwatch ?? this.primarySwatch,
      bgApp: bgApp ?? this.bgApp,
      sidebar: sidebar ?? this.sidebar,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      mutedDim: mutedDim ?? this.mutedDim,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      categoryPalette: categoryPalette ?? this.categoryPalette,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    List<Color> lerpedPalette = [];
    for (int i = 0; i < categoryPalette.length; i++) {
      lerpedPalette.add(Color.lerp(categoryPalette[i], other.categoryPalette[i], t)!);
    }
    return AppColorsExtension(
      primarySwatch: t < 0.5 ? primarySwatch : other.primarySwatch,
      bgApp: Color.lerp(bgApp, other.bgApp, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedDim: Color.lerp(mutedDim, other.mutedDim, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      balance: Color.lerp(balance, other.balance, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      categoryPalette: lerpedPalette,
    );
  }
}

final appColorsLight = AppColorsExtension(
  primarySwatch: LightColors.primarySwatch,
  bgApp: LightColors.bgApp,
  sidebar: LightColors.sidebar,
  card: LightColors.card,
  cardBorder: LightColors.cardBorder,
  border: LightColors.border,
  text: LightColors.text,
  muted: LightColors.muted,
  mutedDim: LightColors.mutedDim,
  income: LightColors.income,
  expense: LightColors.expense,
  balance: LightColors.balance,
  accent: LightColors.accent,
  accentSecondary: LightColors.accentSecondary,
  categoryPalette: LightColors.categoryPalette,
);

final appColorsDark = AppColorsExtension(
  primarySwatch: DarkColors.primarySwatch,
  bgApp: DarkColors.bgApp,
  sidebar: DarkColors.sidebar,
  card: DarkColors.card,
  cardBorder: DarkColors.cardBorder,
  border: DarkColors.border,
  text: DarkColors.text,
  muted: DarkColors.muted,
  mutedDim: DarkColors.mutedDim,
  income: DarkColors.income,
  expense: DarkColors.expense,
  balance: DarkColors.balance,
  accent: DarkColors.accent,
  accentSecondary: DarkColors.accentSecondary,
  categoryPalette: DarkColors.categoryPalette,
);

/// Helper to get colors smoothly animated via ThemeExtension
class AppColors {
  static AppColorsExtension _ext(BuildContext context) => Theme.of(context).extension<AppColorsExtension>()!;

  static MaterialColor primarySwatch(BuildContext context) => _ext(context).primarySwatch;
  static Color bgApp(BuildContext context) => _ext(context).bgApp;
  static Color sidebar(BuildContext context) => _ext(context).sidebar;
  static Color card(BuildContext context) => _ext(context).card;
  static Color cardBorder(BuildContext context) => _ext(context).cardBorder;
  static Color border(BuildContext context) => _ext(context).border;
  static Color text(BuildContext context) => _ext(context).text;
  static Color muted(BuildContext context) => _ext(context).muted;
  static Color mutedDim(BuildContext context) => _ext(context).mutedDim;

  static Color income(BuildContext context) => _ext(context).income;
  static Color expense(BuildContext context) => _ext(context).expense;
  static Color balance(BuildContext context) => _ext(context).balance;
  static Color accent(BuildContext context) => _ext(context).accent;
  static Color accentSecondary(BuildContext context) => _ext(context).accentSecondary;

  static List<Color> categoryPalette(BuildContext context) => _ext(context).categoryPalette;
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    extensions: [appColorsLight],
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
    extensions: [appColorsDark],
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
