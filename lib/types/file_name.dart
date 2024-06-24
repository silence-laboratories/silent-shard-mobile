// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:path/path.dart';

extension FileName on File {
  String get filename => basename(path);
}
