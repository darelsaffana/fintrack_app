import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintrack_app/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ThemeProvider uses light mode by default', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final provider = ThemeProvider();
    await tester.pump();

    expect(provider.themeModeOption, ThemeModeOption.light);
    expect(provider.themeMode, ThemeMode.light);
  });

  testWidgets('ThemeProvider persists selected theme mode', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final provider = ThemeProvider();
    await tester.pump();

    await provider.setThemeMode(ThemeModeOption.dark);

    final reloadedProvider = ThemeProvider();
    await tester.pump();

    expect(provider.themeModeOption, ThemeModeOption.dark);
    expect(provider.themeMode, ThemeMode.dark);
    expect(reloadedProvider.themeModeOption, ThemeModeOption.dark);
    expect(reloadedProvider.themeMode, ThemeMode.dark);
  });
}
