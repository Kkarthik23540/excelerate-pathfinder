// app_theme_splash.dart
// Centralises all design tokens (colours, typography, spacing, radii).
// Every screen imports from here so a single change propagates everywhere.

import 'package:flutter/material.dart';

// ─── Colour palette ──────────────────────────────────────────────────────────
// Extracted directly from the SVG designs.
class AppColors {
  AppColors._();

  // Background used across all screens
  static const Color background = Color(0xFFFBF8FE);

  // Pure white surface
  static const Color surface = Color(0xFFFFFFFF);

  // Primary brand colour
  static const Color primary = Color(0xFFB80C2F);

  // Lighter red
  static const Color primaryLight = Color(0xFFE4BDBD);

  // Purple accent
  static const Color accent = Color(0xFF863CAC);

  // Navigation label
  static const Color navLabel = Color(0xFF5B4040);

  // Text colours
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF6B6B6F);

  // Borders / dividers
  static const Color divider = Color(0xFFE4BDBD);

  // Chip background
  static const Color chipBackground = Color(0xFFF0EDF2);

  // Status colours
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color inactive = Color(0xFFBDBDBD);

  static const Color adminColor = Color(0xFF6366F1);
  static const Color priorityOrange = Color(0xFFFF9800);
  static const Color cardBg = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color learnerColor = Color(0xFF4CAF50);
}
// ─── Typography ──────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // Large page/section headings.
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Section sub-headings.
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body copy – default readable text.
  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Smaller helper / caption text.
  static const TextStyle caption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button label.
  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    letterSpacing: 0.4,
  );

  // Navigation bar label.
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.navLabel,
  );
}

// ─── Spacing & radius constants ───────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Horizontal screen padding.
  static const double screenPadding = 20.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double pill = 100.0;
}

// ─── ThemeData ─────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  // Builds the MaterialApp ThemeData from the tokens above, so that
  // default widget styles also respect our design system.
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
  );
}
