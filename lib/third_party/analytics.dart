// ignore_for_file: constant_identifier_names

// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:silentshard/demo/state_decorators/keyshares_provider.dart';

enum PageSource { sign_in, onboarding_backup, onboarding, homepage, get_started, backup_page }

enum SignInMethod { gmail, apple }

enum PairingDeviceStatus { qr_scanned, success, failed }

enum PairingDeviceType { repaired, recovered, new_account }

enum DistributedKeyGenStatus { initiated, success, failed }

enum DistributedKeyGenType { new_account, recovered }

enum AllowPermissionsNoti { allowed, denied }

enum AllowPermissionsDeviceLock { allowed, denied, na }

enum SignPerformStatus { approved, rejected, success, failed }

enum SaveBackupSystem { google_password, keychain }

enum DeleteAccountStatus { success, cancelled }

enum EventName {
  app_start,
  info_sheet,
  sign_in,
  connect_new_account,
  pairing_device,
  account_created,
  save_backup_system,
  allow_permissions,
  sign_initiated,
  sign_perform,
  device_lock_toggle,
  save_to_file,
  delete_account,
  log_out,
  verify_backup
}

class AnalyticManager {
  late Mixpanel mixpanel;
  static const WALLET_METAMASK = 'MetaMask';
  late KeysharesProvider _keysharesProvider;

  AnalyticManager() {
    initMixpanel();
  }

  set keysharesProvider(KeysharesProvider keysharesProvider) {
    _keysharesProvider = keysharesProvider;
  }

  void initMixpanel() async {
    final token = dotenv.get('MIX_PANEL_TOKEN');
    mixpanel = await Mixpanel.init(token, optOutTrackingDefault: false, trackAutomaticEvents: true);
    mixpanel.setLoggingEnabled(true);
  }

  void trackAppStart() {
    mixpanel.track(EventName.app_start.name);
  }

  void trackInfoSheet(PageSource source) {
    mixpanel.track(EventName.info_sheet.name, properties: {
      "source": source.name,
      "type": "bottom_sheet",
    });
  }

  void trackSignIn({required String emailId, required SignInMethod authMethod, String? error}) {
    mixpanel.track(EventName.sign_in.name, properties: {'email_id': emailId, 'auth': authMethod.name, 'error': error});
  }

  void trackConnectNewAccount() {
    mixpanel.track(EventName.connect_new_account.name);
  }

  void trackPairingDevice({required PairingDeviceType type, required PairingDeviceStatus status, String? wallet, String? error}) {
    mixpanel.track(EventName.pairing_device.name, properties: {
      'type': type.name,
      'status': status.name,
      'error': error,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress()
    });
  }

  void trackDistributedKeyGen(
      {required DistributedKeyGenType type, required DistributedKeyGenStatus status, String? publicKey, String? wallet, String? error}) {
    mixpanel.track(EventName.pairing_device.name,
        properties: {'type': type.name, 'status': status.name, 'error': error, 'wallet': wallet ?? WALLET_METAMASK, 'public_key': publicKey});
  }

  void trackSaveBackupSystem({required bool success, required PageSource source, String? wallet, String? error}) {
    String backup = 'na';
    if (Platform.isAndroid) {
      backup = SaveBackupSystem.google_password.name;
    } else if (Platform.isIOS) {
      backup = SaveBackupSystem.keychain.name;
    }
    mixpanel.track(EventName.save_backup_system.name, properties: {
      'backup': backup,
      'success': success,
      'error': error,
      'source': source.name,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress()
    });
  }

  void trackRecoverBackupSystem({required bool success, required PageSource source, String? wallet, String? error}) {
    String backup = 'na';
    if (Platform.isAndroid) {
      backup = SaveBackupSystem.google_password.name;
    } else if (Platform.isIOS) {
      backup = SaveBackupSystem.keychain.name;
    }
    mixpanel.track(EventName.save_backup_system.name, properties: {
      'backup': backup,
      'success': success,
      'error': error,
      'source': source.name,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress()
    });
  }

  void trackAllowPermissions(
      {AllowPermissionsDeviceLock? deviceLock, AllowPermissionsNoti? notifications, required PageSource source, String? error}) {
    mixpanel.track(EventName.allow_permissions.name,
        properties: {'device_lock': deviceLock?.name, 'notifications': notifications?.name, 'source': source.name, 'error': error});
  }

  void trackSignInitiated({String? transactionId, String? wallet, String? error}) {
    mixpanel.track(EventName.sign_initiated.name,
        properties: {'transaction_id': transactionId, 'from': _getWalletAddress(), 'wallet': wallet ?? WALLET_METAMASK, 'error': error});
  }

  void trackSignPerform({required SignPerformStatus status, String? transactionId, String? wallet, String? error}) {
    mixpanel.track(EventName.sign_perform.name, properties: {
      'status': status.name,
      'transaction_id': transactionId,
      'from': _getWalletAddress(),
      'wallet': wallet ?? WALLET_METAMASK,
      'error': error
    });
  }

  void trackDeviceLockToggle(bool allowed) {
    mixpanel.track(EventName.device_lock_toggle.name, properties: {'allowed': allowed});
  }

  void trackSaveToFile({required bool success, String? backup, String? wallet, required PageSource source, String? error}) {
    mixpanel.track(EventName.save_to_file.name, properties: {
      'backup': backup,
      'success': success,
      'error': error,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress(),
      'source': source.name
    });
  }

  void trackRecoverFromFile({required bool success, String? backup, String? wallet, required PageSource source, String? error}) {
    mixpanel.track(EventName.save_to_file.name, properties: {
      'backup': backup,
      'success': success,
      'error': error,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress(),
      'source': source.name
    });
  }

  void trackDeleteAccount({required DeleteAccountStatus status, bool? backupSystem, bool? backupFile, String? wallet, String? publicKey}) {
    mixpanel.track(EventName.delete_account.name, properties: {
      'status': status.name,
      'backup_system': backupSystem,
      'backup_file': backupFile,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress()
    });
  }

  void trackLogOut() {
    mixpanel.track(EventName.log_out.name);
  }

  void trackVerifyBackup({required bool success, required String timeSinceVerify, PageSource? source, String? wallet, String? error}) {
    String backup = 'na';
    if (Platform.isAndroid) {
      backup = SaveBackupSystem.google_password.name;
    } else if (Platform.isIOS) {
      backup = SaveBackupSystem.keychain.name;
    }
    mixpanel.track(EventName.verify_backup.name, properties: {
      'backup': backup,
      'success': success,
      'time_since_verify': timeSinceVerify,
      'error': error,
      'source': source?.name,
      'wallet': wallet ?? WALLET_METAMASK,
      'public_key': _getWalletAddress()
    });
  }

  String? _getWalletAddress() {
    return _keysharesProvider.keyshares.firstOrNull?.ethAddress;
  }
}
