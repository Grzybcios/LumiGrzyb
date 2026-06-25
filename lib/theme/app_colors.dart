import 'package:flutter/material.dart';

/// Paleta — ciemny motyw Fluent / WinUI 3 z efektem Acrylic.
abstract final class AppColors {
  static const bg = Color(0xFF1C1C1E);

  // Tło okna pozostaje przezroczyste, by przepuszczać rozmazanie Acrylic.
  static const windowBackground = Colors.transparent;

  // Tint nakładany przez efekt Acrylic — ~60% krycia / 40% przezroczystości (styl 60/40).
  static const acrylicTint = Color(0x991C1C1E);

  // Powierzchnie „szklane" — półprzezroczyste, by widać było rozmazane tło.
  static const surface = Color(0x992C2C2E);
  static const cardElevated = Color(0xA63A3A3C);

  // Nieprzezroczyste warianty do okien dialogowych i pól wejściowych.
  static const surfaceOpaque = Color(0xFF2C2C2E);
  static const cardElevatedOpaque = Color(0xFF3A3A3C);

  static const border = Color(0xFF48484A);
  static const separator = Color(0xFF38383A);

  static const text = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF8E8E93);
  static const textDim = Color(0xFF636366);

  static const primary = Color(0xFF0A84FF);
  static const primaryHover = Color(0xFF409CFF);

  static const accent = Color(0xFFFF9F0A);
  static const success = Color(0xFF30D158);
  static const danger = Color(0xFFFF453A);
  static const party = Color(0xFFFF9F0A);
  static const partyHover = Color(0xFFE08F00);
  static const offline = Color(0xFF636366);

  static const btnSecondary = Color(0xFF3A3A3C);
  static const btnSecondaryHover = Color(0xFF48484A);
  static const sliderTrough = Color(0xFF3A3A3C);
}
