import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _navBarHeight = 72.0;
const _navIconSize = 32.0;

/// Material Symbols stroke weight (100-700); 400 is the font default.
const _navIconWeight = 400.0;

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    fontFamilyFallback: const ['Roboto', 'Arial'],
    scaffoldBackgroundColor: AppDesign.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDesign.red,
      primary: AppDesign.red,
      surface: AppDesign.canvas,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: AppDesign.canvas,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: AppDesign.ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppDesign.line, thickness: 1),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppDesign.ink, fontSize: 14),
      bodySmall: TextStyle(fontSize: 12, height: 1.4),
      titleMedium: TextStyle(fontSize: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      selectedColor: AppDesign.red,
      backgroundColor: AppDesign.white,
      side: const BorderSide(color: AppDesign.line),
      shape: const StadiumBorder(),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Inter',
          color: states.contains(WidgetState.selected)
              ? AppDesign.white
              : AppDesign.ink,
          fontSize: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDesign.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppDesign.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppDesign.line),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: _navBarHeight,
      backgroundColor: AppDesign.navBar,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          color: states.contains(WidgetState.selected)
              ? AppDesign.red
              : AppDesign.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: _navIconSize,
          weight: _navIconWeight,
          color: states.contains(WidgetState.selected)
              ? AppDesign.red
              : AppDesign.muted,
        ),
      ),
    ),
  );
  static final dark = light;
}
