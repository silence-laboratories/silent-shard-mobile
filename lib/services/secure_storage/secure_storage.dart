// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'secure_storage_service.dart';
import 'android_secure_storage.dart';
import 'ios_secure_storage.dart';

class SecureStorage implements SecureStorageService {
  late final SecureStorageService _platform;

  SecureStorage() {
    if (Platform.isAndroid) {
      _platform = AndroidSecureStorage();
    } else if (Platform.isIOS) {
      _platform = IosSecureStorage();
    } else {
      throw StateError('Unsupported OS ${Platform.operatingSystem}');
    }
  }

  @override
  Future<void> init() => _platform.init();

  @override
  Future<SecureStorageEntry?> read(String? key) => _platform.read(key);

  @override
  Future<Iterable<String>> readAll() => _platform.readAll();

  @override
  Future<void> write(SecureStorageEntry entry) => _platform.write(entry);

  @override
  Future<void> delete(String key) => _platform.delete(key);
}
