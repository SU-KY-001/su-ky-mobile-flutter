import 'package:flutter/material.dart';

abstract final class AppDesign {
  static const red = Color(0xFF922522);
  static const canvas = Color(0xFFFAF9F7);
  static const ink = Color(0xFF202020);
  static const muted = Color(0xFF85817E);
  static const line = Color(0xFFECE9E6);
  static const tint = Color(0xFFF6EFED);
  static const white = Colors.white;
  static const pagePadding = 24.0;
  static const gap = 16.0;
  static const radius = 16.0;
  static const maxWidth = 520.0;
  static const cover = 'assets/images/bach_dang.jpg';
  static const secondCover = 'assets/images/dong_a.jpg';
  static const thumbnails = [
    'assets/images/dam_da.jpg',
    'assets/images/me_linh.jpg',
    'assets/images/thang_long.jpg',
  ];
  static const episodeSeconds = [1575, 1725, 2050, 1370, 1650, 1540];
  static const initialPosition = 860;
  static const seekStep = 15;
  static const sleepMinutes = 15;
}

extension SuKeTheme on BuildContext {
  Color get accent => Theme.of(this).colorScheme.primary;
  TextTheme get text => Theme.of(this).textTheme;
}
