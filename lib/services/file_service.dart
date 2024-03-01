// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<(File?, String?)> selectFile() {
    return FilePicker.platform.pickFiles().then((value) {
      final path = value?.files.single.path;
      final filePickerId = value?.files.single.identifier;
      return (path != null) ? (File(path), filePickerId) : (null, null);
    });
  }

  Future<File> createTemporaryFile(String filename) {
    return getTemporaryDirectory() //
        .then((tempDirectory) => File('${tempDirectory.path}/$filename.txt'));
  }
}
