// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

final class SecureStorageEntry {
  final String key;
  final String value;

  const SecureStorageEntry(this.key, this.value);
}

abstract interface class SecureStorageService {
  Future<void> init();

  // *key*:
  // android - must be null
  // ios - must be non-null
  Future<SecureStorageEntry?> read(String? key);

  // Supported only on iOS, returns empty map on android
  Future<Iterable<String>> readAll();

  Future<void> write(SecureStorageEntry value);

  // Supported only on iOS, returns empty future on android
  Future<void> delete(String key);
}
