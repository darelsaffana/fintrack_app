import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeModeOption == ThemeModeOption.dark;

    return InkWell(
      onTap: () => themeProvider.setThemeMode(
        isDark ? ThemeModeOption.light : ThemeModeOption.dark,
      ),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBorder(context).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            final rotation = Tween<double>(
              begin: isDark ? 0.8 : 0.0,
              end: isDark ? 0.0 : 0.8,
            ).animate(animation);
            final scale = Tween<double>(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
            return FadeTransition(
              opacity: animation,
              child: RotationTransition(
                turns: rotation,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey<bool>(isDark),
            color: AppColors.text(context),
            size: 24,
          ),
        ),
      ),
    );
  }
}
