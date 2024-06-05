// ignore_for_file: constant_identifier_names

// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum PageSource { sign_in, onboarding_backup, onboarding, homepage, get_started, backup_page }

enum SignInStatus { success, failed }

enum PairingDeviceStatus { qr_scanned, success, failed }

enum PairingDeviceType { repaired, recovered, new_account }

enum DistributedKeyGenStatus { initiated, success, failed }

enum DistributedKeyGenType { new_account, recovered }

enum AllowPermissionsNoti { allowed, denied }

enum AllowPermissionsDeviceLock { allowed, denied, na }

enum SignPerformStatus { approved, rejected, success, failed }

enum SaveBackupSystem { google_password, keychain }

enum DeleteAccountStatus { success, cancelled }

enum BackupEntropy { password, seed }

enum BackupValidity { corrupt, valid }

enum EventName {
  app_start,
  info_sheet,
  sign_in,
  connect_new_account,
  pairing_device,
  distributed_keys_generated,
  account_created,
  save_backup_system,
  recover_backup_system,
  allow_permissions,
  sign_initiated,
  sign_perform,
  device_lock_toggle,
  save_to_file,
  recover_from_file,
  delete_account,
  log_out,
  verify_backup,
  backup_found,
  corrupt_backup_detected,
  notification_click
}

const WALLET_ID_NOT_FOUND = "Wallet ID not found";
const ADDRESS_NOT_FOUND = "Address not found";
const WALLET_MISMATCH = "wallet mismatch";

class AnalyticManager {
  late Mixpanel mixpanel;
  AnalyticManager();

  Future<void> init() async {
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

  void identifyUserProfile(String id) {
    mixpanel.identify(id);
  }

  void setUserProfileProps({required String prop, required String value}) {
    mixpanel.getPeople().set(prop, value);
  }

  void trackSignIn({required String userId, required SignInStatus status, String? error}) {
    mixpanel.track(EventName.sign_in.name, properties: {'user_id': userId, 'status': status.name, 'error': error});
  }

  void trackConnectNewAccount() {
    mixpanel.track(EventName.connect_new_account.name);
  }

  void trackPairingDevice(
      {required PairingDeviceType type, required PairingDeviceStatus status, required String address, required String wallet, String? error}) {
    mixpanel.track(EventName.pairing_device.name,
        properties: {'type': type.name, 'status': status.name, 'error': error, 'wallet': wallet, 'public_key': address});
  }

  void trackDistributedKeyGen(
      {required DistributedKeyGenType type, required DistributedKeyGenStatus status, String? address, required String wallet, String? error}) {
    mixpanel.track(EventName.distributed_keys_generated.name,
        properties: {'type': type.name, 'status': status.name, 'error': error, 'wallet': wallet, 'public_key': address});
  }

  void trackSaveBackupSystem({required bool success, required PageSource source, required String address, required String wallet, String? error}) {
    String backup = _getBackupSystem();
    mixpanel.track(EventName.save_backup_system.name,
        properties: {'backup': backup, 'success': success, 'error': error, 'source': source.name, 'wallet': wallet, 'public_key': address});
  }

  void trackRecoverBackupSystem({required bool success, required PageSource source, required String wallet, required String address, String? error}) {
    String backup = _getBackupSystem();
    mixpanel.track(EventName.recover_backup_system.name, properties: {
      'backup': backup,
      'success': success,
      'error': error,
      'source': source.name,
      'wallet': wallet,
      'public_key': address,
    });
  }

  void trackAllowPermissions(
      {AllowPermissionsDeviceLock? deviceLock, AllowPermissionsNoti? notifications, required PageSource source, String? error}) {
    mixpanel.track(EventName.allow_permissions.name,
        properties: {'device_lock': deviceLock?.name, 'notifications': notifications?.name, 'source': source.name, 'error': error});
  }

  void trackSignInitiated({required String wallet, required String from, String? error}) {
    mixpanel.track(EventName.sign_initiated.name, properties: {'from': from, 'wallet': wallet, 'error': error});
  }

  void trackSignPerform({required SignPerformStatus status, required String wallet, required String from, String? error}) {
    mixpanel.track(EventName.sign_perform.name, properties: {'status': status.name, 'from': from, 'wallet': wallet, 'error': error});
  }

  void trackDeviceLockToggle(bool allowed) {
    mixpanel.track(EventName.device_lock_toggle.name, properties: {'allowed': allowed});
  }

  void trackSaveToFile(
      {required bool success, required String address, required String wallet, String? backup, required PageSource source, String? error}) {
    mixpanel.track(EventName.save_to_file.name,
        properties: {'backup': backup, 'success': success, 'error': error, 'wallet': wallet, 'public_key': address, 'source': source.name});
  }

  void trackRecoverFromFile(
      {required bool success, required String address, required String wallet, String? backup, required PageSource source, String? error}) {
    mixpanel.track(EventName.recover_from_file.name,
        properties: {'backup': backup, 'success': success, 'error': error, 'wallet': wallet, 'public_key': address, 'source': source.name});
  }

  void trackDeleteAccount(
      {required DeleteAccountStatus status, bool? backupSystem, bool? backupFile, required String wallet, required String address}) {
    mixpanel.track(EventName.delete_account.name,
        properties: {'status': status.name, 'backup_system': backupSystem, 'backup_file': backupFile, 'wallet': wallet, 'public_key': address});
  }

  void trackLogOut() {
    mixpanel.track(EventName.log_out.name);
  }

  void trackVerifyBackup(
      {required bool success, required String timeSinceVerify, PageSource? source, required String wallet, required String address, String? error}) {
    String backup = _getBackupSystem();
    mixpanel.track(EventName.verify_backup.name, properties: {
      'backup': backup,
      'success': success,
      'time_since_verify': timeSinceVerify,
      'error': error,
      'source': source?.name,
      'wallet': wallet,
      'public_key': address
    });
  }

  void trackBackupFound({required String walletId, required bool isValid}) {
    mixpanel.track(EventName.backup_found.name, properties: {
      'entropy': walletId == METAMASK_WALLET_ID ? BackupEntropy.seed.name : BackupEntropy.password.name,
      'validity': isValid ? BackupValidity.valid.name : BackupValidity.corrupt.name,
      'wallet': walletId,
    });
  }

  void trackCorruptBackupDetected({required String walletId, required String address}) {
    mixpanel.track(EventName.corrupt_backup_detected.name, properties: {'wallet': walletId, 'public_key': address});
  }

  void trackNotificationClick({required String userId, required String notificationTitle}) {
    mixpanel.track(EventName.notification_click.name, properties: {'user_id': userId, 'notification_title': notificationTitle});
  }

  String _getBackupSystem() {
    if (Platform.isAndroid) {
      return SaveBackupSystem.google_password.name;
    } else if (Platform.isIOS) {
      return SaveBackupSystem.keychain.name;
    }
    return 'na';
  }
}
