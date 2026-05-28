/// Web stub for dart:io File.
class File {
  File(this.path);
  final String path;

  void writeAsStringSync(String contents, {FileMode mode = FileMode.write}) {}
}

enum FileMode { write, append }
