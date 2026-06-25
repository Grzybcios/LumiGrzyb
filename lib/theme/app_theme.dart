import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData build() {
    const family = 'Segoe UI';
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.windowBackground,
      fontFamily: family,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceOpaque,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.danger,
        onSurface: AppColors.text,
        onPrimary: AppColors.text,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: family,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
        ),
        titleMedium: TextStyle(
          fontFamily: family,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        bodyMedium: TextStyle(
          fontFamily: family,
          fontSize: 13,
          color: AppColors.text,
        ),
        bodySmall: TextStyle(
          fontFamily: family,
          fontSize: 11,
          color: AppColors.textMuted,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.sliderTrough,
        thumbColor: AppColors.text,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceOpaque,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
