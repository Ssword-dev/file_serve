part of platform;

class _R {
  const _R();

  /// Constructs a RegExp with the given pattern
  /// uses special item indexing form as syntactic sugar
  /// for regex creation
  RegExp operator [](String pattern) {
    return RegExp(pattern);
  }
}

const _R R = _R();
