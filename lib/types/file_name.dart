import 'dart:io';

import 'package:path/path.dart';

extension FileName on File {
  String get filename => basename(path);
}
