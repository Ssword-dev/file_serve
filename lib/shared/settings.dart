import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_serve/shared/preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  final UserPreferences pref;
  const SettingsPage({super.key, required this.pref});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserPreferences userPreferences;

  @override
  void initState() {
    super.initState();
    userPreferences = widget.pref;
  }

  Widget _buildSettingsTile({
    required Widget icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _toggleTheme() {
    setState(() {
      if (userPreferences.theme == UserThemePreference.light) {
        userPreferences.theme = UserThemePreference.dark;
      } else if (userPreferences.theme == UserThemePreference.dark) {
        userPreferences.theme = UserThemePreference.light;
      }
    });
  }

  void _ternaryToggleContrast() {
    setState(() {
      userPreferences.contrast =
          (userPreferences.contrast + 1) %
          UserConstrastPreference.values.length;
      print(userPreferences.scheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: FaIcon(FontAwesomeIcons.moon),
            title: 'Theme',
            onTap: _toggleTheme,
          ),
          _buildSettingsTile(
            icon: Icon(Icons.contrast),
            title: 'Contrast',
            onTap: _ternaryToggleContrast,
          ),
        ],
      ),
    );
  }
}
