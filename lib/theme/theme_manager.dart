import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  final ThemeMode _themeMode = ThemeMode.dark;

  get themeMode => _themeMode;
}
