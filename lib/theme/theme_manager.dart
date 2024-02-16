// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  final ThemeMode _themeMode = ThemeMode.dark;

  get themeMode => _themeMode;
}
