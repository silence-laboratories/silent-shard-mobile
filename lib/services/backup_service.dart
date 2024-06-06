// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/utils.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
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
        _analyticManager.trackRecoverFromFile(
            wallet: appBackup.walletId,
            address: appBackup.walletBackup.accounts.firstOrNull?.address ?? ADDRESS_NOT_FOUND,
            success: true,
            source: PageSource.get_started,
            backup: backupDestination);
        return appBackup;
      }
    } catch (error) {
      _analyticManager.trackRecoverFromFile(
          wallet: WALLET_ID_NOT_FOUND,
          address: ADDRESS_NOT_FOUND,
          success: false,
          source: PageSource.get_started,
          backup: backupDestination,
          error: error.toString());
      rethrow;
    }
    return null;
  }

  Future<AppBackup?> readBackupFromStorage(String? key) async {
    try {
      final entry = await _secureStorage.read(key);
      if (entry != null) {
        final appBackup = AppBackup.fromString(entry.value);
        _analyticManager.trackRecoverBackupSystem(
            wallet: appBackup.walletId,
            address: appBackup.walletBackup.accounts.firstOrNull?.address ?? ADDRESS_NOT_FOUND,
            success: true,
            source: PageSource.get_started);
        return appBackup;
      }
    } catch (error) {
      _analyticManager.trackRecoverBackupSystem(
          wallet: WALLET_ID_NOT_FOUND,
          address: ADDRESS_NOT_FOUND,
          success: false, //
          source: PageSource.get_started,
          error: parseCredentialExceptionMessage(error));
      rethrow;
    }
    return null;
  }

  // -------------------- Save --------------------

  Future<File> saveBackupToFile(String walletId, AppBackup backup) {
    final ethAddress = backup.walletBackup.accounts.firstOrNull?.address;
    if (ethAddress == null) return Future.error(ArgumentError('Cannot backup wallet with no accounts'));

    final filename = '${ethAddress.substring(0, 7)}-${DateTime.now().toString().substring(0, 10)}-$walletId-backup';

    return _fileService.createTemporaryFile(filename).then((file) => file.writeAsString(backup.toString()));
  }

  void backupToFileDidSave(AppBackup backup) {
    _updateBackupInfo(backup, (info) {
      info.file = BackupCheck(BackupStatus.done);
    });
  }

  Future<void> saveBackupToStorage(String walletId, AppBackup backup) {
    final ethAddress = backup.walletBackup.accounts.firstOrNull?.address;
    if (ethAddress == null) return Future.error(ArgumentError('Cannot backup wallet with no accounts'));
    final entry = SecureStorageEntry('$walletId-$ethAddress', backup.toString());
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

  Future<BackupInfo> getBackupInfo(String address, {String walletId = ''}) async {
    final info = _preferences.backupInfo(address);
    if (!Platform.isIOS) return info;
    await _setupKeychainBackupInfo(info, address, walletId);
    return info;
  }

  Future<void> verifyBackup(String address) async {
    if (!Platform.isAndroid) return;
    final info = _preferences.backupInfo(address);
    try {
      final backup = await readBackupFromStorage(null);
      if (backup != null) {
        if (backup.walletBackup.accounts.firstOrNull?.address != address) {
          throw ArgumentError(CANNOT_VERIFY_BACKUP);
        }
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

  Future<void> _setupKeychainBackupInfo(BackupInfo info, String address, String walletId) async {
    if (walletId == METAMASK_WALLET_ID) {
      await _setupMetaMaskKeychainBackupInfo(info, address, walletId);
    } else {
      var key = '$walletId-$address';
      if (!(_hasCheckedKeychain[key] ?? false)) {
        _hasCheckedKeychain[key] = true;

        try {
          final appBackup = await readBackupFromStorage(key);
          if (appBackup != null) {
            info.keychain = BackupCheck(BackupStatus.done, appBackup.time);
            _setBackupInfo(info);
          } else if (info.keychain.status == BackupStatus.done) {
            info.keychain = BackupCheck(BackupStatus.missing);
            _setBackupInfo(info);
          }
        } catch (e) {
          if (info.keychain.status == BackupStatus.done) {
            info.keychain = BackupCheck(BackupStatus.missing);
            _setBackupInfo(info);
          }
        }
      }
    }
  }

  Future<void> _setupMetaMaskKeychainBackupInfo(BackupInfo info, String address, String walletId) async {
    Map<String, AppBackup?> backupEntries = {address: null, '$walletId-$address': null};
    for (var key in backupEntries.keys) {
      if (_hasCheckedKeychain.containsKey(key) && _hasCheckedKeychain[key] == true) {
        return;
      }
      _hasCheckedKeychain[key] = true;
      try {
        final appBackup = await readBackupFromStorage(key);
        if (appBackup != null) {
          backupEntries[key] = appBackup;
        }
      } catch (e) {
        backupEntries[key] = null;
      }
    }

    final appBackup = backupEntries.values.firstWhere((element) => element != null, orElse: () => null);
    if (appBackup != null) {
      info.keychain = BackupCheck(BackupStatus.done, appBackup.time);
      _setBackupInfo(info);
    } else if (info.keychain.status == BackupStatus.done) {
      info.keychain = BackupCheck(BackupStatus.missing);
      _setBackupInfo(info);
    }
  }

  void _setBackupInfo(BackupInfo backupInfo) {
    _preferences.setBackupInfo(backupInfo);
    notifyListeners();
  }
}
