import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../generated/app_colors.dart';
import '../generated/app_radius.dart';
import '../generated/app_typography.dart';
import 'app_theme_extension.dart';

/// As duas variantes de tema do protótipo React (`data-theme="light"|"gbMode"`).
/// Não é o `ThemeMode` do Flutter (light/dark/system) — `gbMode` é uma identidade de marca,
/// não um modo escuro genérico.
enum AppThemeVariant { light, gbMode }

/// Monta o `ThemeData` de uma variante a partir dos tokens gerados (F1.2) — nunca hardcoded.
ThemeData buildAppTheme(AppThemeVariant variant) {
  final semantic = variant == AppThemeVariant.light ? AppSemanticColors.light : AppSemanticColors.gbMode;
  final brightness = variant == AppThemeVariant.light ? Brightness.light : Brightness.dark;

  final textTheme = GoogleFonts.outfitTextTheme().copyWith(
    displayLarge: GoogleFonts.outfit(fontSize: AppTypography.xl4, fontWeight: AppTypography.weightBold, color: semantic.fgDefault),
    headlineMedium: GoogleFonts.outfit(fontSize: AppTypography.xl3, fontWeight: AppTypography.weightBold, color: semantic.fgDefault),
    titleLarge: GoogleFonts.outfit(fontSize: AppTypography.xl2, fontWeight: AppTypography.weightSemibold, color: semantic.fgDefault),
    titleMedium: GoogleFonts.outfit(fontSize: AppTypography.xl, fontWeight: AppTypography.weightSemibold, color: semantic.fgDefault),
    bodyLarge: GoogleFonts.outfit(fontSize: AppTypography.lg, fontWeight: AppTypography.weightNormal, color: semantic.fgDefault),
    bodyMedium: GoogleFonts.outfit(fontSize: AppTypography.md, fontWeight: AppTypography.weightNormal, color: semantic.fgMuted),
    bodySmall: GoogleFonts.outfit(fontSize: AppTypography.sm, fontWeight: AppTypography.weightNormal, color: semantic.fgSubtle),
    labelLarge: GoogleFonts.outfit(fontSize: AppTypography.md, fontWeight: AppTypography.weightMedium, color: semantic.fgDefault),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: semantic.bgCanvas,
    canvasColor: semantic.bgCanvas,
    fontFamily: textTheme.bodyMedium?.fontFamily,
    textTheme: textTheme,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: semantic.accentDefault,
      onPrimary: semantic.accentContrast,
      secondary: AppColors.brand500,
      onSecondary: semantic.accentContrast,
      error: AppColors.red600,
      onError: Colors.white,
      surface: semantic.bgSurface,
      onSurface: semantic.fgDefault,
    ),
    dividerColor: semantic.borderDefault,
    cardTheme: CardThemeData(
      color: semantic.bgSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: semantic.accentDefault,
        foregroundColor: semantic.accentContrast,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: semantic.bgSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: semantic.borderDefault),
      ),
    ),
    extensions: [semantic],
  );
}
