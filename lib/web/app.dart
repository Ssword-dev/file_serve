import 'package:flutter/material.dart';
import 'package:file_serve/config.dart';
import 'package:file_serve/shared/interfaces.dart';
import 'package:file_serve/shared/preferences.dart';
import 'package:file_serve/shared/settings.dart';
import 'package:file_serve/transitions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class App extends StatelessWidget {
  final Config appConfig;
  final UserPreferences userPreferences = UserPreferences();
  App({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // flags
      debugShowCheckedModeBanner: appConfig.flags['showDebugTag'] ?? true,
      title: 'Flutter Server',
      theme: ThemeData(
        colorScheme: userPreferences.scheme,
        fontFamily: "Geist",
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/releases': (context) => const InstallPage(),
        '/settings': (context) => SettingsPage(pref: UserPreferences()),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Flutter Server",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Serve, sync, and share across your network.",
                style: TextStyle(
                  fontSize: 18,
                  color: color.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/releases');
                },
                child: const Text("Install / Releases"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstallPage extends StatelessWidget {
  const InstallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Install Flutter Server"),
        backgroundColor: color.primary,
      ),
      backgroundColor: color.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Download and Install",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Choose your platform below and follow the instructions to install the Flutter Server app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 220,
                    child: FilledButton.icon(
                      onPressed: () {
                        // link or trigger to mobile/desktop builds
                      },
                      icon: const Icon(Icons.phone_android),
                      label: const Text("Download for Android"),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: FilledButton.icon(
                      onPressed: () {
                        // link to install instructions
                      },
                      icon: const Icon(Icons.desktop_windows),
                      label: const Text("Download for Desktop"),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: FilledButton.icon(
                      onPressed: () {},
                      label: const Text("Github Source Code"),
                      icon: Icon(FontAwesomeIcons.github),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
