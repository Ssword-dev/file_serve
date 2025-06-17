import 'package:flutter/material.dart';
import 'package:file_serve/shared/interfaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_serve/config.dart';

/// Can be "normal" or "high"
///
/// high contrast can be beneficial for visibility
class UserConstrastPreference {
  static const int normal = 0;
  static const int high = 1;

  /// Reduces glare, but still a little bit of contrast
  static const int lowGlare = 2;
  static const List<int> values = [normal, high, lowGlare];
}

/// Believe it or not, this is an "enum".
/// and unlike real dart enums (object)
/// this thing enable super fast switch-case
/// to be compiled in native platforms (through C)
/// ```c
/// enum UserThemePreference {
///    light,
///    dark,
/// }
/// ```
class UserThemePreference {
  static const int light = 0;
  static const int dark = 1;

  /// The
  static const List<int> values = [light, dark];
}

class UserPreferences extends ChangeNotifier {
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();

  final Config config = appConfig;
  late SharedPreferences _prefs;
  bool _initialized = false;

  int _theme = UserThemePreference.light;
  int _contrast = UserConstrastPreference.normal;

  /// access current theme value
  int get theme => _theme;

  set theme(int value) {
    if (_theme != value) {
      _theme = value;
      _prefs.setInt('theme-preference', value);
      notifyListeners();
    }
  }

  int get contrast => _contrast;

  set contrast(int value) {
    if (_contrast != value) {
      _contrast = value;
      _prefs.setInt('contrast-preference', value);
      notifyListeners();
    }
  }

  ColorScheme get scheme {
    if (!_initialized) {
      return config.colorSchemeLight;
    }
    switch (_theme) {
      case UserThemePreference.light:
        switch (_contrast) {
          case UserConstrastPreference.normal:
            return config.colorSchemeLight;
          case UserConstrastPreference.high:
            return config.colorSchemeHighContrastLight;
          case UserConstrastPreference.lowGlare:
            return config.colorSchemeLowGlareLight;
          default:
            return config.colorSchemeLight;
        }
      case UserThemePreference.dark:
        switch (_contrast) {
          case UserConstrastPreference.normal:
            return config.colorSchemeDark;
          case UserConstrastPreference.high:
            return config.colorSchemeHighContrastDark;
          case UserConstrastPreference.lowGlare:
            return config.colorSchemeLowGlareDark;
          default:
            return config.colorSchemeLight;
        }
      default:
        return config.colorSchemeLight;
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    await _prefs.reload();
    const int initValue = 0;
    final storedInit = _prefs.getInt('x-initialization');
    if (storedInit != initValue) {
      await _prefs.setInt('x-initialization', initValue);
      await _prefs.setInt('theme-preference', UserThemePreference.light);
      await _prefs.setInt(
        'contrast-preference',
        UserConstrastPreference.normal,
      );
    }

    _theme = _prefs.getInt('theme-preference') ?? UserThemePreference.light;
    _contrast =
        _prefs.getInt('contrast-preference') ?? UserConstrastPreference.normal;

    _initialized = true;
    notifyListeners();
  }
}
