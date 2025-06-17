import 'package:flutter/material.dart';
import 'package:file_serve/shared/preferences.dart';
import 'config.dart';
import 'native/app.dart'
    if (dart.library.html) 'web/app.dart'; // app is defined in these, each contains different pieces
// of code, the web app

/// The entrypoint of the app itself, the app is defined at compile time
/// and is split between 2 routes, native, or web
Future<void> main() async {
  await UserPreferences().init();
  runApp(App(appConfig: appConfig));
}
