// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';

import 'package:hashlib/hashlib.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

final class AppBackup {
  static const currentVersion = 2;

  final int version;
  final DateTime time;
  final WalletBackup walletBackup;
  final String walletId;

  AppBackup(this.walletBackup, this.walletId, [this.version = currentVersion, DateTime? backupTime])
      : time = backupTime?.toUtc() ?? DateTime.timestamp() {
    if (version <= 0) {
      throw ArgumentError('Invalid backup version');
    }
  }

  @override
  String toString() => jsonEncode(toJson());

  factory AppBackup.fromString(String jsonString) {
    if (jsonString.length < 100 || jsonString.length > 100000) {
      throw ArgumentError('Backup data is invalid');
    }
    final json = jsonDecode(jsonString);
    return AppBackup.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'time': time.toIso8601String(),
      'wallet': walletBackup.toJson(),
      'walletId': walletId,
      'hash': _hash,
    };
  }

  String get toCanonicalJsonString => '{"time":"${time.toIso8601String()}","version":$version,"wallet":${walletBackup.toCanonicalJsonString}}';

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    final wallet = json['wallet'];
    final time = json['time'];
    final hash = json['hash'];

    final walletId = version == 1 ? METAMASK_WALLET_ID : json['walletId'];

    if (version is! int || wallet is! List<dynamic> || time is! String || hash is! String) {
      throw ArgumentError('Backup data is invalid');
    }

    final parsedTime = DateTime.parse(time);
    final walletBackup = WalletBackup.fromJson(wallet);
    final appBackup = AppBackup(walletBackup, walletId, version, parsedTime);

    if (hash != appBackup._hash) {
      throw ArgumentError('Backup data is corrupted');
    }

    return appBackup;
  }

  String get _hash {
    final dataToHash = utf8.encode(toCanonicalJsonString);
    final hash = keccak256.convert(dataToHash);
    return hash.hex();
  }
}
