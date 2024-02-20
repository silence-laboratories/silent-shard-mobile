// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';
import 'dart:io';

enum BackupStatus {
  pending, // user has not yet undertaken backup action
  done, // user has completed backup action
  missing; // backup action was completed, but backup was not found in place
}

final class BackupCheck {
  final BackupStatus status;
  final DateTime date;

  BackupCheck([this.status = BackupStatus.pending, DateTime? dateTime]) : date = dateTime ?? DateTime.now();

  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'status': status.index,
        'check': date.microsecondsSinceEpoch,
      };

  BackupCheck.fromJson(Map<String, dynamic> json)
      : status = BackupStatus.values[json['status']],
        date = DateTime.fromMicrosecondsSinceEpoch(json['check']);
}

final class BackupInfo {
  final String address;
  BackupCheck file;
  BackupCheck passwordManager; // valid only on android
  BackupCheck keychain; // valid only on iOS

  BackupInfo(
    this.address, {
    BackupCheck? aFile,
    BackupCheck? aPasswordManager,
    BackupCheck? aKeychain,
  })  : file = aFile ?? BackupCheck(),
        passwordManager = aPasswordManager ?? BackupCheck(),
        keychain = aKeychain ?? BackupCheck();

  BackupCheck get cloud => Platform.isAndroid ? passwordManager : keychain;

  set cloud(BackupCheck check) => Platform.isAndroid ? passwordManager = check : keychain = check;

  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'address': address,
        'file': file.toJson(),
        'passwordManager': passwordManager.toJson(),
        'keychain': keychain.toJson(),
      };

  BackupInfo.fromJson(Map<String, dynamic> json)
      : address = json['address'],
        file = BackupCheck.fromJson(json['file']),
        passwordManager = BackupCheck.fromJson(json['passwordManager']),
        keychain = BackupCheck.fromJson(json['keychain']);
}
