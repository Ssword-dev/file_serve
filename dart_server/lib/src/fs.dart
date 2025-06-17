part of app.library.dart_server;

// controls the maximum time before a cached file expires
const Duration ttlFileExpiry = Duration(seconds: 300);

class VirtualFileSystemOwnershipError extends Error {
  final String? message;
  VirtualFileSystemOwnershipError([this.message]);

  @override
  String toString() {
    return 'VirtualFileSystemOwnershipError: $message';
  }
}

class VirtualFileStat {
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final int size;
  final FileSystemEntityType type;
  final String Function() modeString;
  final int mode;

  VirtualFileStat(FileStat stat)
    : changed = stat.changed,
      modified = stat.modified,
      accessed = stat.accessed,
      size = stat.size,
      type = stat.type,
      modeString = stat.modeString,
      mode = stat.mode;

  @override
  String toString() {
    return 'FileStatSnapshot('
        'type: $type, size: $size, '
        'modified: $modified, accessed: $accessed, changed: $changed, '
        'mode: $mode ($modeString))';
  }
}

/// Base class for all VirtualFileSystemEntity
///
/// the VirtualFileSystemEntity can only and shall be created only
/// by the VirtualFileSystem instance itself.
///
/// Enforced via the [owner] named parameter, this makes sure different file
/// systems does not try to **overwrite** data from another file system
///
/// by default, file system entities are only the **metadata** of the entity itself, not
/// the actual file system entity itself
class VirtualFileSystemEntity {
  final VirtualFileSystem _owner;
  const VirtualFileSystemEntity({required VirtualFileSystem owner})
    : _owner = owner;
}

/// A file construct
///
/// notice i said construct there, this isnt actually
/// a file, this is just metadata
class VirtualFile extends VirtualFileSystemEntity {
  final String path;
  const VirtualFile({required super.owner, required this.path});
}

/// A directory construct
///
/// notice i said construct there, this isnt actually
/// a directory, this is just metadata

class VirtualDirectory extends VirtualFileSystemEntity {
  final String path;
  final List<VirtualFileSystemEntity> children;
  VirtualDirectory({
    required super.owner,
    required this.path,
    required this.children,
  });
}

class VirtualFileCacheTimer {
  final VirtualFileSystem fileSystem;
  final VirtualFile file;

  /// The underlying timer for the decay of the file
  ///
  /// note:
  Timer timer;
  VirtualFileCacheTimer({required this.fileSystem, required this.file})
    : timer = Timer(ttlFileExpiry, () {
        fileSystem._fsFileCache.remove(file.path);
      });

  /// Renews the timer
  Future<void> renew() async {
    timer.cancel();
    timer = Timer(ttlFileExpiry, () {
      fileSystem._fsFileCache.remove(file.path);
    });
  }
}

/// The actual cached metadata about a given file
///
/// includes: stat, contents, the vfile itself, and the timer associated with this
class VirtualFileCache {
  Uint8List contents;
  VirtualFileStat stat;
  final VirtualFile file;
  final VirtualFileCacheTimer ttlTimer;
  bool exists;

  /// A cache value for the cache in the parent filesystem
  VirtualFileCache({
    required this.contents,
    required this.stat,
    required this.file,
    required this.exists,
  }) : ttlTimer = VirtualFileCacheTimer(fileSystem: file._owner, file: file);
}

/// A high level abstraction over the file system
class VirtualFileSystem {
  final Map<String, VirtualFileCache> _fsFileCache;
  VirtualFileSystem() : _fsFileCache = {};
  void _assertOwnership(VirtualFileSystemEntity entity) {
    if (entity._owner != this) {
      throw VirtualFileSystemOwnershipError(
        "Cannot access an entity not owned by the current instance",
      );
    }
  }

  /// Returns a contents of a file in a **stream**
  ///
  /// this allows for very memory-efficient but also fast
  /// transfer (atleast i hope, because if i just wrote this for
  /// nothing then...)
  Future<Stream<Uint8List>> readFile(VirtualFile file) async {
    _assertOwnership(file);

    if (_fsFileCache.containsKey(file.path)) {
      return Stream.fromIterable([_fsFileCache[file.path]!.contents]);
    }

    // there is no cache, we have to manually read from a file

    try {
      File f = File(file.path);
      Uint8List contents = await f.readAsBytes();

      // set the cache value

      FileStat stat = await FileStat.stat(file.path);
      _fsFileCache[file.path] = VirtualFileCache(
        contents: contents,
        stat: VirtualFileStat(stat),
        file: file,
        exists: true, // if we are reading to it now, it means it exist
      );

      return Stream.fromIterable([contents]);
    } catch (_) {
      rethrow; // rethrow os errors... this allows us to listen for os errors and react to it. tl;dr: preserve error
    }
  }

  Future<void> writeFile(VirtualFile file, Uint8List contents) async {
    _assertOwnership(file);

    File f = File(file.path);
    IOSink sink = f.openWrite();

    await sink.addStream(Stream<Uint8List>.fromIterable([contents]));
    await sink.close();

    // refresh if cached
    if (_fsFileCache.containsKey(file.path)) {
      VirtualFileCache cache = _fsFileCache[file.path]!;
      cache.contents = contents;
      cache.stat = VirtualFileStat(await FileStat.stat(file.path));
      cache.exists = true; // if we are writing to it, it means it exist
      await cache.ttlTimer.renew();
    }
  }

  Future<bool> exists(VirtualFile file) async {
    _assertOwnership(file);
    if (_fsFileCache.containsKey(file.path)) {
      return _fsFileCache[file.path]!.exists;
    }

    // read the file contents and cache if it exists, this is called "taking the opportunity"
    File f = File(file.path);
    bool exists = await f.exists();

    if (exists) {
      _fsFileCache[file.path] = VirtualFileCache(
        contents: await f.readAsBytes(),
        stat: VirtualFileStat(await FileStat.stat(f.path)),
        file: file,
        exists: exists,
      );

      return true;
    }

    return false; // dont cache on file not exist.
  }
}
