import '../lib/platform/platform.dart';

int main() {
  print(
    path.resolve(
      "./dart-server/bin/dart_server.dart",
      "C:/Users/ssword-dev/Desktop",
    ),
  );

  print(path.ext("t.with-ext"));
  return 0;
}
