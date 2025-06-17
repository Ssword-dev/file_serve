part of app.library.dart_server;

/// A set of "primitive" utilities that dart_server uses
class DartServerUtilityPrimitives {
  static Future<T?> resolveBefore<T>(
    Duration duration,
    Future<T> future,
  ) async {
    Completer<T> completer = Completer();

    _setDelayedFallback<T>(duration, completer);
    _resolveIfComplete<T>(future, completer);

    return await completer.future;
  }

  static void _setDelayedFallback<T>(
    Duration duration,
    Completer<T> completer,
  ) {
    Future.delayed(duration, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
  }

  static void _resolveIfComplete<T>(Future<T> future, Completer<T> completer) {
    future.then((val) {
      if (!completer.isCompleted) {
        completer.complete(val);
      }
    });
  }
}

class DartServerUtilityComposites {
  static Future<bool> runtimeIsAvailable(IsolateRuntime runtime) async {
    PingProtocol pingProtocol = PingProtocol();
    await runtime.sendProtocol(pingProtocol);
    final pong = await DartServerUtilityPrimitives.resolveBefore(
      Duration(seconds: 2),
      runtime.awaitNext(),
    );

    if (pong == null) {
      return false;
    }

    return !pong['isManagingServer'] || false;
  }
}
