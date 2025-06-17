part of platform;

class Path {
  const Path();
  String get seperator => Platform.isWindows ? "\\" : "/";

  /// Joins together paths
  String join(List<String> paths) {
    return paths.join(seperator);
  }

  List<String> split(String path) {
    return path.split(seperator);
  }

  /// Resolves a path
  ///
  /// Thats the tl;dr
  ///
  /// Under the hood, checks if `path[0]` is `/`
  /// if it is, we join `from` and `path` except `path[0]`
  /// is not included
  ///
  /// this is to remove the `/` aka the "root-relative" path operator
  ///
  /// if the first character (`path[0]`) is not `/`
  /// then the path itself is joined to `from`
  ///
  /// this effectively resolves the path in 3n iterations (taking the probability of not being windows)
  /// in hand.
  ///
  /// this means this algorithm has O(n) time complexity and O(1)
  /// space complexity (internally, there is only 3 things we keep track of)
  /// because we only keep track of the original path (this is before the loop),
  /// the path segments (original) and finally, the resolved path segments
  ///
  /// do note that this throws an error if there is no more paths to go back to
  /// and yes, if going back means the path will be empty, it will throw an error
  String resolve(String path, String from) {
    if (path[0] == "/") {
      path = join([from, path.substring(1, path.length)]);
    } else {
      path = join([from, path]);
    }
    path = fix(path);
    // attempt to normalize the path
    // first, split the path
    List<String> segments = split(path);
    List<String> newSegments = [];

    for (String segment in segments) {
      // it is actually simple, if we encounter a segment that is
      // "." which is the "current directory" operator, we dont do anything.
      // ".." which is "previous directory" operator, we dont do anything
      switch (segment) {
        case ".":
          continue;
        case "..":
          // this means
          if (newSegments.length < 2) {
            throw "Cannot resolve path, there is no more segments to step down to";
          }

          newSegments.removeLast();
          break;
        default:
          newSegments.add(segment);
      }
    }
    return join(newSegments);
  }

  /// For a given path, returns the path without the last segment
  String dirname(String path) {
    path = fix(path); // Attempt to fix path if we are on windows
    List<String> segments = split(path);
    // this excludes the last segment
    return join(segments.sublist(0, segments.length - 1));
  }

  /// Fixes a path
  ///
  /// Welp, that's the tl;dr but what it does is
  /// if dart says this executable is compiled for
  /// windows (for windows).
  ///
  /// Then path.fix will turn all unix `/` into windows `\\`
  String fix(String path) {
    if (Platform.isWindows) {
      return path.replaceAll("/", "\\");
    }

    return path;
  }

  String ext(String path) {
    return R[r"(\.[a-zA-Z0-9_\-]+)$"].firstMatch(path)?.group(1) ?? path;
  }
}

const Path path = Path();
