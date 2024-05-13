// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../types/backup_info.dart';

class AppPreferences extends ChangeNotifier {
  final SharedPreferences _sharedPreferences;

  AppPreferences(this._sharedPreferences);

  // isLocalAuthRequired
  bool getIsLocalAuthRequired() {
    return _sharedPreferences.getBool('isLocalAuthRequired') ?? false;
  }

  void setIsLocalAuthRequired(bool value) {
    _sharedPreferences.setBool('isLocalAuthRequired', value);
    notifyListeners();
  }

  // isOnboardingCompleted
  bool getIsOnboardingCompleted() {
    return _sharedPreferences.getBool('isOnboardingCompleted') ?? false;
  }

  void setIsOnboardingCompleted(bool value) {
    _sharedPreferences.setBool('isOnboardingCompleted', value);
    notifyListeners();
  }

  bool getIsPasswordReady(String address) {
    return _sharedPreferences.getBool('isPasswordReady_$address') ?? false;
  }

  void setIsPasswordReady(String address, bool value) {
    _sharedPreferences.setBool('isPasswordReady_$address', value);
    notifyListeners();
  }

  BackupInfo backupInfo(String address) {
    final jsonString = _sharedPreferences.getString(address);
    final json = jsonString != null ? jsonDecode(jsonString) : null;
    return json != null ? BackupInfo.fromJson(json) : BackupInfo(address);
  }

  void setBackupInfo(BackupInfo info) {
    final jsonString = jsonEncode(info.toJson());
    _sharedPreferences.setString(info.address, jsonString);
    notifyListeners();
  }
}
