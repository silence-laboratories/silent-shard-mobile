// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/third_party/analytics.dart';

import '../types/demo_decorator.dart';

class BackupsProvider extends ChangeNotifier with DemoDecorator {
  final BackupState _backupState;
  final AnalyticManager _analyticManager;
  Map<String, WalletBackup>? _demoWalletBackups;

  Map<String, WalletBackup> get walletBackupsMap => _demoWalletBackups ?? _backupState.walletBackupsMap;

  bool isBackupAvailable(String walletId, String address) {
    final walletBackup = walletBackupsMap[walletId];
    if (walletBackup == null) return false;

    for (AccountBackup account in walletBackup.accounts) {
      if (account.address == address) {
        final isValid = _validateBackup(account);
        _analyticManager.trackBackupFound(walletId: walletId, isValid: isValid);
        return isValid;
      }
    }
    return false;
  }

  bool _validateBackup(AccountBackup backup) {
    return backup.remoteData.length != NULL_ENCRYPTED_LENGTH;
  }

  BackupsProvider(this._backupState, this._analyticManager) {
    _backupState.addListener(() => notifyListeners());
  }

  @override
  void startDemoMode() {
    super.startDemoMode();
    _demoWalletBackups = {"metamask": DemoWalletBackup()};
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
