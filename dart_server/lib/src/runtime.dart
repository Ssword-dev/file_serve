part of app.library.dart_server;

class DartServerCreationStatus {
  static const int success = 0,
      noAvailableRuntime = 1,
      tookTooLong = 2,
      fatalError = 3;
  static const List<int> values = [
    success,
    noAvailableRuntime,
    tookTooLong,
    fatalError,
  ];
}

abstract class IsolateProtocol {
  final String protocolKind;
  const IsolateProtocol({required this.protocolKind});

  dynamic serialize() => {"protocolKind": protocolKind};

  static String serializeProtocol(IsolateProtocol protocol) {
    return json.encode(protocol.serialize());
  }
}

mixin UuidProtocol on IsolateProtocol {
  String get uuid;
  @override
  serialize() => {...super.serialize(), "uuid": uuid};
}

mixin MessageDataProtocol on IsolateProtocol {
  String get message;
  Map<String, dynamic>? get data;
  @override
  serialize() => {...super.serialize(), "message": message, "data": data};
}

mixin ErrorStackProtocol on IsolateProtocol {
  String get error;
  String? get stackTrace;
  @override
  serialize() => {
    ...super.serialize(),
    "error": error,
    "stackTrace": stackTrace,
  };
}

class _InitializationIsolateProtocol extends IsolateProtocol with UuidProtocol {
  @override
  final String uuid;
  const _InitializationIsolateProtocol({required this.uuid})
    : super(protocolKind: "initialization");
}

class _AcknowledgementIsolateProtocol extends IsolateProtocol
    with UuidProtocol {
  @override
  final String uuid;
  const _AcknowledgementIsolateProtocol({required this.uuid})
    : super(protocolKind: "acknowledgement");

  factory _AcknowledgementIsolateProtocol.fromSerializedInitialization(
    Map<String, dynamic> serialized,
  ) {
    return _AcknowledgementIsolateProtocol(uuid: serialized['uuid']);
  }
}

class _DataRejectionProtocol extends IsolateProtocol {
  final dynamic serializedProtocol;
  final String? reason;
  final String? description;

  const _DataRejectionProtocol({
    required this.serializedProtocol,
    this.reason,
    this.description,
  }) : super(protocolKind: "rejection");

  @override
  serialize() => {
    ...super.serialize(),
    "serializedProtocol": serializedProtocol,
    "reason": reason,
    "description": description,
  };
}

class ServerCreationProtocol extends IsolateProtocol {
  final int port;
  final String rootDirectory;
  ServerCreationProtocol({required this.port, required this.rootDirectory})
    : super(protocolKind: "serverCreation");

  @override
  serialize() => {
    ...super.serialize(),
    "port": port,
    "rootDirectory": rootDirectory,
  };
}

class ServerCreatedProtocol extends IsolateProtocol {
  final int port;
  final String rootDirectory;

  ServerCreatedProtocol({required this.port, required this.rootDirectory})
    : super(protocolKind: "serverCreated");

  @override
  serialize() => {
    ...super.serialize(),
    "port": port,
    "rootDirectory": rootDirectory,
  };
}

class ServerDestructionProtocol extends IsolateProtocol {
  final String reason;
  ServerDestructionProtocol({required this.reason})
    : super(protocolKind: "serverDestruction");

  @override
  serialize() => {...super.serialize(), "reason": reason};
}

class PingProtocol extends IsolateProtocol {
  const PingProtocol() : super(protocolKind: "ping");
}

class PongProtocol extends IsolateProtocol {
  final bool isManagingServer;
  final int? serverPort;
  final String? rootDirectory;

  PongProtocol({
    required this.isManagingServer,
    this.serverPort,
    this.rootDirectory,
  }) : super(protocolKind: "pong");

  @override
  serialize() => {
    ...super.serialize(),
    "isManagingServer": isManagingServer,
    "serverPort": serverPort,
    "rootDirectory": rootDirectory,
  };
}

class ExitProtocol extends IsolateProtocol {
  ExitProtocol() : super(protocolKind: "exit");
}

ExitProtocol _exitProtocolInstance = ExitProtocol();

class IsolateRuntime {
  Isolate? isolate;
  bool initialized;
  SendPort? isolateSendPort;
  String uuid;
  late ReceivePort receivePort;
  late StreamQueue _queue;
  IsolateRuntime()
    : initialized = false,
      uuid = _DartServerGlobals.globalUuid.v4() {
    receivePort = ReceivePort();
    _queue = StreamQueue(receivePort.asBroadcastStream());
    final sendPort = receivePort.sendPort;
    _beginIntrinsicInitialization(receivePort, sendPort);
  }

  Future<void> _beginIntrinsicInitialization(
    ReceivePort receivePort,
    SendPort sendPort,
  ) async {
    Isolate $isolate = await Isolate.spawn(
      IsolateRuntime.runtimeHandle,
      sendPort,
    );
    isolate = $isolate;
    isolateSendPort = await _queue.next as SendPort;

    var initialization = _InitializationIsolateProtocol(uuid: uuid);
    isolateSendPort!.send(IsolateProtocol.serializeProtocol(initialization));

    Map<String, dynamic>? ack = await DartServerUtilityPrimitives.resolveBefore(
      Duration(seconds: 10),
      awaitNext(),
    );

    if (ack == null) {
      throw "Acknowledgement did not resolve in the first 10 seconds";
    }

    if (ack['protocolKind'] != "acknowledgement" || ack['uuid'] != uuid) {
      throw "Runtime sent an invalid acknowlegement protocol!";
    }
  }

  /// This method assumes the runtime has received initialization
  /// and has received the send port itself
  /// note: this also may not resolve quickly leading to poor app
  /// performance, that is why i reccomend if you are gonna listen to
  /// any events (even though you should not) is to use [DartServerUtilityPrimitives.resolveBefore]
  Future<Map<String, dynamic>> awaitNext() async {
    try {
      final msg = await _queue.next;
      if (msg is! String) {
        throw FormatException(
          "Expected message to be a JSON string, got: $msg",
        );
      }

      final decoded = json.decode(msg);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException("Expected decoded JSON to be a map");
      }

      return decoded;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Internal only. USE THE APIS!!!!
  Future<void> sendProtocol(IsolateProtocol protocol) async {
    //// good to know i was sending in the receive port of the main isolate itself
    //// probably could have ended badly
    final port = isolateSendPort;
    port!.send(IsolateProtocol.serializeProtocol(protocol));
  }

  static void runtimeHandle(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    bool initializationHandshakeReceived = false;
    DartServer? $server;
    String? $rootDirectory;
    int? $serverPort;

    Future<int> destroyServer() async {
      if ($server != null) {
        await $server!.close();
        $serverPort = null;
        $rootDirectory = null;
        $server = null;
        return 0;
      }
      return 1;
    }

    createServer(String rootDirectory, int serverPort) async {
      await destroyServer();
      $rootDirectory = rootDirectory;
      $serverPort = serverPort;
      $server = DartServer(
        port: serverPort,
        rootDirectory: Directory(rootDirectory),
      );

      $server!.start();

      // ! no, this is not the scp you are thinking of. this means ServerCreatedProtocol
      final scp = ServerCreatedProtocol(
        port: serverPort,
        rootDirectory: rootDirectory,
      );
      mainSendPort.send(IsolateProtocol.serializeProtocol(scp));
    }

    void sendRejection(dynamic msg, {String? reason, String? description}) {
      print(msg);
      final rejection = _DataRejectionProtocol(
        serializedProtocol: msg,
        reason: reason,
        description: description,
      );
      mainSendPort.send(IsolateProtocol.serializeProtocol(rejection));
    }

    port.listen((msg) async {
      dynamic data;
      try {
        data = json.decode(msg);
        if (data is! Map<String, dynamic> || data['protocolKind'] == null) {
          throw "";
        }
      } catch (_) {
        sendRejection(msg);
        return;
      }

      switch (data['protocolKind']) {
        case "initialization":
          if (!initializationHandshakeReceived) {
            initializationHandshakeReceived = true;
            final ack =
                _AcknowledgementIsolateProtocol.fromSerializedInitialization(
                  data,
                );

            print("Sending ack...");
            mainSendPort.send(IsolateProtocol.serializeProtocol(ack));
          }
          break;

        case "serverCreation":
          print("Creation protocol received");
          if (!initializationHandshakeReceived) {
            sendRejection(msg);
            return;
          }

          if (data['rootDirectory'] is! String ||
              !Directory(data['rootDirectory']).existsSync()) {
            sendRejection(
              msg,
              reason: "DirectoryNotFound",
              description: "The specified root directory does not exist.",
            );
            return;
          }

          if (data['port'] is! int) {
            sendRejection(msg, reason: "Port should be an integer");
            return;
          }
          print("Creating the server...");
          await createServer(data['rootDirectory'], data['port']);
          break;

        case "serverDestruction":
          if (await destroyServer() == 1) {
            sendRejection(msg, reason: "There is no server to destruct");
          }
          break;

        case "ping":
          final pong = PongProtocol(
            isManagingServer: $server != null,
            serverPort: $serverPort,
            rootDirectory: $rootDirectory,
          );
          print(pong);
          mainSendPort.send(IsolateProtocol.serializeProtocol(pong));
          break;

        case "exit":
          destroyServer();
          Isolate.exit();
      }
    });

    Future.delayed(Duration(seconds: 10), () async {
      await Future.delayed(Duration(seconds: 1));
      if (!initializationHandshakeReceived) {
        Isolate.exit();
      }
    });
  }
}

class RuntimeIsolatePool {
  static RuntimeIsolatePool? _instance;
  final int isolateCount;
  final List<IsolateRuntime> _runtimes;

  RuntimeIsolatePool._internal({required this.isolateCount})
    : _runtimes = List.generate(isolateCount, (_) => IsolateRuntime());

  factory RuntimeIsolatePool({required int isolateCount}) {
    return _instance ??= RuntimeIsolatePool._internal(
      isolateCount: isolateCount,
    );
  }

  static RuntimeIsolatePool get instance {
    if (_instance == null) {
      throw Exception(
        'RuntimeIsolatePool has not been initialized. Call RuntimeIsolatePool(isolateCount: ...) first.',
      );
    }
    return _instance!;
  }

  Future<List<IsolateRuntime>?> runtimesAvailable() async {
    final results = await Future.wait(
      _runtimes.map(
        (runtime) async =>
            (await DartServerUtilityComposites.runtimeIsAvailable(runtime))
                ? runtime
                : null,
      ),
    );
    List<IsolateRuntime> availableRuntimes =
        results.whereType<IsolateRuntime>().toList();
    return availableRuntimes.isEmpty ? null : availableRuntimes;
  }

  Future<IsolateRuntime?> runtimeAvailable() async {
    return (await runtimesAvailable())?.first;
  }

  Future<int> createServer(int port, String rootDirectory) async {
    IsolateRuntime? runtime = await runtimeAvailable();
    if (runtime == null) {
      return DartServerCreationStatus
          .noAvailableRuntime; // we cannot find any available runtime
    }

    final creationProtocol = ServerCreationProtocol(
      port: port,
      rootDirectory: rootDirectory,
    );

    runtime.sendProtocol(creationProtocol);
    final scp = await DartServerUtilityPrimitives.resolveBefore(
      Duration(milliseconds: 500),
      runtime.awaitNext(),
    );

    if (scp == null) {
      return DartServerCreationStatus
          .tookTooLong; // the created protocol was not sent before 500 ms
    }
    if (scp['port'] != port) {
      return DartServerCreationStatus
          .fatalError; // wrong port, fatal error, race condition
    }

    return DartServerCreationStatus.success; // success
  }

  Future<void> terminateServer(int port) async {
    /// what this does is gets all occupied runtime, then do a filter.
    /// then if there is any runtime of the same port given, then terminate
    /// the server. not the runtime itself. remember, this is pooling. a singleton pooling
    final runtimes = await runtimesAvailable();
    if (runtimes == null) return;

    for (final runtime in runtimes) {
      final pong = await DartServerUtilityPrimitives.resolveBefore(
        Duration(seconds: 2),
        runtime.awaitNext(),
      );
      if (pong != null && pong['serverPort'] == port) {
        await runtime.sendProtocol(
          ServerDestructionProtocol(reason: "Terminated by pool"),
        );
      }
    }
  }

  /// Asyncronously kills all runtimes.
  ///
  /// !!! Use only at exit !!!
  void killAllRuntimes() {
    for (final runtime in _runtimes) {
      // we dont await here as we do not have any i/o operations
      // that is too critical to leave (most OS will close them if the exit protocol did not)
      // run before the OS kills the process forcefully
      // oh, also. this would
      runtime.sendProtocol(_exitProtocolInstance);
    }
  }
}
