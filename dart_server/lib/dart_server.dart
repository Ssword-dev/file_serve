/// This library is part of the file_serve app and is not meant to be used
/// directly

// ignore: unnecessary_library_name
library app.library.dart_server;

import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:vmservice_io';
import 'dart:developer'; // for debugging s... because why not
import 'package:async/async.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
// Sub library for platform path stuff
import 'platform/platform.dart';

part 'src/utilities.dart';
part 'src/globals.dart';
part 'src/mime_guesser.dart';

// aggressive caching (for repeated requests)
part 'src/fs.dart';
part 'src/server.dart';
part 'src/runtime.dart';
