import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Printer {
  static final Printer _instance = Printer._internal();
  final StreamController<String> _controller = StreamController.broadcast();

  Printer._internal();

  factory Printer() => _instance;

  /// Stream of printed messages.
  Stream<String> get onPrint => _controller.stream;

  /// Print a message and notify listeners.
  void print(Object? message) {
    final msg = message?.toString() ?? 'null';
    _controller.add(msg);
  }

  /// Dispose the stream controller when done.
  void dispose() {
    _controller.close();
  }
}

Printer printer = Printer();

class PrinterListener extends InheritedWidget {
  final Stream<String> printStream;

  const PrinterListener({
    super.key,
    required super.child,
    required this.printStream,
  });

  static PrinterListener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrinterListener>();
  }

  @override
  bool updateShouldNotify(PrinterListener oldWidget) {
    return printStream != oldWidget.printStream;
  }
}
