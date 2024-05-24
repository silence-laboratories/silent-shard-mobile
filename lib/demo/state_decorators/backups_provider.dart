// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

import '../types/demo_decorator.dart';

class BackupsProvider extends ChangeNotifier with DemoDecorator {
  final BackupState _backupState;
  Map<String, WalletBackup>? _demoWalletBackups;

  Map<String, WalletBackup> get walletBackupsMap => _demoWalletBackups ?? _backupState.walletBackupsMap;

  bool isBackupAvailable(String walletId, String address) {
    final walletBackup = walletBackupsMap[walletId];
    if (walletBackup == null) return false;
    return walletBackup.accounts.any((accountBackup) => accountBackup.address == address);
  }

  BackupsProvider(this._backupState) {
    _backupState.addListener(() => notifyListeners());
  }

  @override
  void startDemoMode() {
    super.startDemoMode();
    _demoWalletBackups = {"DemoWalletId": DemoWalletBackup()};
    notifyListeners();
  }

  @override
  void stopDemoMode() {
    super.stopDemoMode();
    _demoWalletBackups = null;
    notifyListeners();
  }
}

class DemoWalletBackup extends WalletBackup {}
