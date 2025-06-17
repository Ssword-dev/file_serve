import 'package:flutter/material.dart';
import 'package:dart_server/dart_server.dart';
import 'package:file_serve/shared/interfaces.dart';
import 'package:file_serve/shared/preferences.dart';
import 'package:file_serve/shared/settings.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

class App extends StatefulWidget {
  final Config appConfig;
  const App({super.key, required this.appConfig});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPreferences()),
        ChangeNotifierProvider(create: (_) => ServerListProvider()),
      ],
      child: Consumer<UserPreferences>(
        builder: (context, userPref, child) {
          return MaterialApp(
            debugShowCheckedModeBanner:
                widget.appConfig.flags['showDebugTag'] ?? true,
            title: 'Flutter Server',
            theme: ThemeData(colorScheme: userPref.scheme),
            initialRoute: "/",
            routes: {
              "/": (context) => HomePage(title: "Flutter Server"),
              "/settings": (context) => SettingsPage(pref: userPref),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;
  final nameController = TextEditingController();
  final portController = TextEditingController();
  final dirController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final servers = context.watch<ServerListProvider>().servers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Geist",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).pushNamed("/settings"),
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          const VerticalDivider(thickness: 2, width: 1),
          Expanded(
            child: Container(
              height: double.infinity,
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        const Text(
                          "Servers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...servers.map(
                          (server) => TruncatableListTile(
                            icon: const Icon(Icons.storage),
                            title: server.name,
                            subtitle: "Port: ${server.port}",
                            badge: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Handle server selection
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add New Server'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Server Name',
                      ),
                    ),
                    TextField(
                      controller: portController,
                      decoration: const InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: dirController,
                      decoration: const InputDecoration(
                        labelText: 'Directory',
                        suffixIcon: Icon(Icons.folder_open),
                      ),
                      readOnly: true,
                      onTap: () async {
                        String? directory =
                            await getDirectoryPath(); // do stuff
                        if (directory != null) {
                          dirController.text = directory;
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final port = int.tryParse(portController.text.trim());
                      final dir = dirController.text.trim();
                      if (name.isNotEmpty && port != null && dir.isNotEmpty) {
                        context.read<ServerListProvider>().addServer(
                          ServerInfo(
                            name: name,
                            port: port,
                            directoryRoot: dir,
                          ),
                        );

                        Navigator.of(
                          context,
                        ).pop({'name': name, 'port': port, 'dir': dir});
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add a new server',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TruncatableListTile extends StatelessWidget {
  final Widget icon;
  final Widget? badge;
  final String subtitle;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TruncatableListTile({
    super.key,
    required this.icon,
    this.badge,
    required this.subtitle,
    required this.title,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: icon,
      trailing: badge,
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
    );
  }
}

class ServerInfo {
  final String name;
  final int port;
  final String directoryRoot;
  ServerInfo({
    required this.name,
    required this.port,
    required this.directoryRoot,
  });
}

class ServerListProvider extends ChangeNotifier {
  final List<ServerInfo> _servers = [];
  final RuntimeIsolatePool pool = RuntimeIsolatePool(isolateCount: 4);

  List<ServerInfo> get servers => _servers;

  Future<void> addServer(ServerInfo server) async {
    _servers.add(server);
    pool.createServer(server.port, server.directoryRoot);
    notifyListeners();
  }

  void removeServer(ServerInfo server) {
    _servers.remove(server);
    pool.terminateServer(server.port);
    notifyListeners();
  }

  void updateServer(int index, ServerInfo newServer) {
    _servers[index] = newServer;
    notifyListeners();
  }
}
