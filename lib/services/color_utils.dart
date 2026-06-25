import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Odpowiednik colorsys + konwersji Hue w ui.py.
abstract final class ColorUtils {
  static String hsvToHex(int hue, int sat, int bri) {
    final h = hue / 65535.0;
    final s = sat / 254.0;
    final v = math.max(0.45, math.min(1.0, bri / 254.0));
    final color = HSVColor.fromAHSV(1, h * 360, s, v).toColor();
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static ({int hue, int sat, int bri}) rgbToHue({
    required double r,
    required double g,
    required double b,
  }) {
    final hsv = HSVColor.fromColor(
      Color.fromARGB(255, r.round(), g.round(), b.round()),
    );
    final hueVal = (hsv.hue / 360 * 65535).round();
    final satVal = (hsv.saturation * 254).round();
    final briVal = hsv.value > 0.05 ? (hsv.value * 254).round() : 10;
    return (hue: hueVal, sat: satVal, bri: briVal);
  }

  static String lightsCountLabel(int count) {
    if (count == 1) return '1 lampa';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return '$count lampy';
    }
    return '$count lamp';
  }
}
