// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_service.dart';

class IosSecureStorage implements SecureStorageService {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> init() => Future.value();

  @override
  Future<SecureStorageEntry?> read(String? key) {
    if (key == null) return Future.error(ArgumentError("IosSecureStorage: key must not be null"));
    return _storage
        .read(key: key) //
        .then((value) => value != null ? SecureStorageEntry(key, value) : null);
  }

  @override
  Future<Iterable<String>> readAll() {
    return _storage
        .readAll() //
        .then((value) => value.entries.map((e) => e.key));
  }

  @override
  Future<void> write(SecureStorageEntry entry) {
    return _storage.write(key: entry.key, value: entry.value);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}
