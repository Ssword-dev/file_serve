part of app.library.dart_server;

class MimeGuesser {
  const MimeGuesser();
  String guessMime(String filePath) {
    return lookupMimeType(filePath) ?? 'application/octet-stream';
  }
}
