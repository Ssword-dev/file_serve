import 'package:flutter/material.dart';
import 'package:file_serve/transitions.dart';
import 'shared/interfaces.dart';

const SophisticatedTransitionBuilder transitionBuilder =
    ExaggeratedSwipeTransitionBuilder();

/// The core of this app's functionality
///
/// note: we cannot use anything client-only or server-only here.
/// this is a shared config, and every co
const Config appConfig = Config(
  transitionBuilder: transitionBuilder,
  flags: {"showDebugTag": false},
);
