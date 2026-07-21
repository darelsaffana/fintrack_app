# fintrack_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Dark Mode Notes

- Theme state is managed by `ThemeProvider` and persisted with `SharedPreferences`.
- The app defaults to `ThemeMode.system`, so first launch follows the device theme automatically.
- Light and dark color tokens live in `lib/core/theme.dart`.
- To change future colors, update the matching token in `LightColors` or `DarkColors`, then reuse `AppColors.<token>(context)` inside widgets.
- The manual theme switch is available in the profile screen and supports `system`, `light`, and `dark`.
- If a UI bug appears only in one mode, check for hardcoded `Colors.*` values in that widget and replace them with `AppColors` or theme-based colors.
