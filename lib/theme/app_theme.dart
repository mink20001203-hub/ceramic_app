import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: OudColors.text,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: OudColors.bg,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: OudColors.primary,
        secondary: OudColors.sage,
        surface: OudColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: OudColors.bg,
        foregroundColor: OudColors.text,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 58,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: OudColors.text,
        ),
      ),
      cardTheme: const CardThemeData(
        color: OudColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: OudRadii.lg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OudColors.surface,
        hintStyle: const TextStyle(color: OudColors.mutedText),
        enabledBorder: OutlineInputBorder(
          borderRadius: OudRadii.md,
          borderSide: const BorderSide(color: OudColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: OudRadii.md,
          borderSide: const BorderSide(color: OudColors.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OudColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: OudRadii.pill),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OudColors.text,
          side: const BorderSide(color: OudColors.border),
          shape: const RoundedRectangleBorder(borderRadius: OudRadii.pill),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: OudColors.primarySoft,
        backgroundColor: OudColors.surface,
        side: const BorderSide(color: Colors.transparent),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          color: OudColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
