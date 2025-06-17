import 'package:flutter/material.dart';
import 'package:file_serve/transitions.dart';

class Config {
  final ColorScheme colorSchemeLight;
  final ColorScheme colorSchemeDark;
  final ColorScheme colorSchemeHighContrastLight;
  final ColorScheme colorSchemeHighContrastDark;
  final ColorScheme colorSchemeLowGlareLight;
  final ColorScheme colorSchemeLowGlareDark;
  final SophisticatedTransitionBuilder transitionBuilder;
  final Map<String, bool> flags;

  const Config({
    this.colorSchemeLight = const ColorScheme.light(),
    this.colorSchemeDark = const ColorScheme.dark(),
    this.colorSchemeHighContrastLight = const ColorScheme.highContrastLight(
      primary: Color(0xff6200ee),
    ),
    this.colorSchemeHighContrastDark = const ColorScheme.highContrastDark(
      primary: Color(0xffbb86fc),
    ),
    this.colorSchemeLowGlareLight = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF6A8CAF),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFB0C4DE),
      onSecondary: Color(0xFF000000),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
      background: Color(0xFFF5F7FA),
      onBackground: Color(0xFF1A1A1A),
      surface: Color(0xFFE9EEF3),
      onSurface: Color(0xFF1A1A1A),
    ),
    this.colorSchemeLowGlareDark = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF8CAFD1),
      onPrimary: Color(0xFF1A1A1A),
      secondary: Color(0xFFB0C4DE),
      onSecondary: Color(0xFF1A1A1A),
      error: Color(0xFFCF6679),
      onError: Color(0xFF1A1A1A),
      background: Color(0xFF23272E),
      onBackground: Color(0xFFE9EEF3),
      surface: Color(0xFF2C313A),
      onSurface: Color(0xFFE9EEF3),
    ),
    required this.transitionBuilder,
    this.flags = const {},
  });
}

abstract class AbstractPrinter {
  void print(Object o);
  Stream<String> get onPrint;
}
