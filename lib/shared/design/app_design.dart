import 'package:flutter/material.dart';

abstract final class AppDesign {
  static const red = Color(0xFF922522);
  static const canvas = Color(0xFFFAF9F7);
  static const ink = Color(0xFF202020);
  static const muted = Color(0xFF85817E);
  static const line = Color(0xFFECE9E6);
  static const tint = Color(0xFFF6EFED);
  static const navBar = Color(0xFFF1EFEF);
  static const white = Colors.white;
  static const pagePadding = 24.0;
  static const gap = 16.0;
  static const radius = 16.0;
  static const maxWidth = 520.0;
}

extension SuKeTheme on BuildContext {
  Color get accent => Theme.of(this).colorScheme.primary;
  TextTheme get text => Theme.of(this).textTheme;
}
