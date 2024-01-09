import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<File?> selectFile() {
    return FilePicker.platform.pickFiles().then((value) {
      final path = value?.files.single.path;
      return (path != null) ? File(path) : null;
    });
  }

  Future<File> createTemporaryFile(String filename) {
    return getTemporaryDirectory() //
        .then((tempDirectory) => File('${tempDirectory.path}/$filename.txt'));
  }
}
