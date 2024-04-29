// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/utils.dart';

import 'app_preferences.dart';
import '../types/backup_info.dart';
import 'file_service.dart';
import '../types/app_backup.dart';
import 'secure_storage/secure_storage_service.dart';

enum BackupSource { fileSystem, secureStorage }

enum BackupDestination { fileSystem, secureStorage }

class BackupService extends ChangeNotifier {
  final FileService _fileService;
  final SecureStorageService _secureStorage;
  final AppPreferences _preferences;
  final AnalyticManager _analyticManager;

  // Optimization to fetch backup from keychain only once per launch
  final Map<String, bool> _hasCheckedKeychain = {};

  BackupService(this._fileService, this._secureStorage, this._preferences, this._analyticManager);

  // -------------------- Read --------------------

  Future<AppBackup?> fetchBackup(BackupSource source, String? key) {
    return switch (source) {
      BackupSource.fileSystem => readBackupFromFile(),
      BackupSource.secureStorage => readBackupFromStorage(key),
    };
  }

  Future<AppBackup?> readBackupFromFile() async {
    late String? backupDestination;
    try {
      final (file, filePickerId) = await _fileService.selectFile();
      backupDestination = filePickerId;
      if (file != null) {
        final fileContent = await file.readAsString();
        final appBackup = AppBackup.fromString(fileContent);
        _analyticManager.trackRecoverFromFile(success: true, source: PageSource.get_started, backup: backupDestination);
        return appBackup;
      }
    } catch (error) {
      _analyticManager.trackRecoverFromFile(success: false, source: PageSource.get_started, backup: backupDestination, error: error.toString());
      rethrow;
    }
    return null;
  }

  Future<AppBackup?> readBackupFromStorage(String? key) async {
    try {
      final entry = await _secureStorage.read(key);
      if (entry != null) {
        final appBackup = AppBackup.fromString(entry.value);
        _analyticManager.trackRecoverBackupSystem(success: true, source: PageSource.get_started);
        return appBackup;
      }
    } catch (error) {
      _analyticManager.trackRecoverBackupSystem(
          success: false, //
          source: PageSource.get_started,
          error: parseCredentialExceptionMessage(error));
      rethrow;
    }
    return null;
  }

  // -------------------- Save --------------------

  Future<void> saveBackup(AppBackup backup, BackupDestination destination) {
    return switch (destination) {
      BackupDestination.fileSystem => saveBackupToFile(backup),
      BackupDestination.secureStorage => saveBackupToStorage(backup),
    };
  }

  Future<File> saveBackupToFile(AppBackup backup) {
    final ethAddress = backup.walletBackup.accounts.firstOrNull?.address;
    if (ethAddress == null) return Future.error(ArgumentError('Cannot backup wallet with no accounts'));

    final filename = '${ethAddress.substring(0, 7)}-${DateTime.now().toString().substring(0, 10)}-silentshard-wallet-backup';

    return _fileService.createTemporaryFile(filename).then((file) => file.writeAsString(backup.toString()));
  }

  void backupToFileDidSave(AppBackup backup) {
    _updateBackupInfo(backup, (info) {
      info.file = BackupCheck(BackupStatus.done);
    });
  }

  Future<void> saveBackupToStorage(AppBackup backup) {
    final entry = SecureStorageEntry(backup.walletBackup.accounts.first.address, backup.toString());
    return _secureStorage //
        .write(entry)
        .then((_) => backupToStorageDidSave(backup));
  }

  void backupToStorageDidSave(AppBackup backup) {
    _updateBackupInfo(backup, (info) {
      info.cloud = BackupCheck(BackupStatus.done);
    });
  }

  void _updateBackupInfo(AppBackup backup, void Function(BackupInfo) updater) {
    for (var account in backup.walletBackup.accounts) {
      final info = _preferences.backupInfo(account.address);
      updater(info);
      _preferences.setBackupInfo(info);
    }

    if (backup.walletBackup.accounts.isNotEmpty) {
      notifyListeners();
    }
  }

  // -------------------- Info --------------------

  BackupInfo getBackupInfo(String address) {
    final info = _preferences.backupInfo(address);

    if (Platform.isIOS && !(_hasCheckedKeychain[address] ?? false)) {
      _hasCheckedKeychain[address] = true;
      readBackupFromStorage(address).then((backup) {
        if (backup != null) {
          info.keychain = BackupCheck(BackupStatus.done, backup.time);
          _setBackupInfo(info);
        } else if (info.keychain.status == BackupStatus.done) {
          // TODO: auto-save backup on iOS
          info.keychain = BackupCheck(BackupStatus.missing);
          _setBackupInfo(info);
        }
      }, onError: (e) {
        if (info.keychain.status == BackupStatus.done) {
          // TODO: auto-save backup on iOS
          info.keychain = BackupCheck(BackupStatus.missing);
          _setBackupInfo(info);
        }
      });
    }

    return info;
  }

  Future<void> verifyBackup(String address) async {
    if (!Platform.isAndroid) return;

    final info = _preferences.backupInfo(address);

    try {
      final backup = await readBackupFromStorage(address);
      if (backup != null) {
        backupToStorageDidSave(backup);
      } else if (info.passwordManager.status == BackupStatus.done) {
        info.passwordManager = BackupCheck(BackupStatus.missing);
        _setBackupInfo(info);
      }
    } catch (error) {
      if (error is CredentialException && error.code == 201) return; // ingore user cancellation

      if (info.passwordManager.status == BackupStatus.done) {
        info.passwordManager = BackupCheck(BackupStatus.missing);
        _setBackupInfo(info);
      }
    }
  }

  void _setBackupInfo(BackupInfo backupInfo) {
    _preferences.setBackupInfo(backupInfo);
    notifyListeners();
  }
}
