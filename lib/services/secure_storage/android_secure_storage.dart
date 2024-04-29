// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:credential_manager/credential_manager.dart';
import 'package:silentshard/constants.dart';

import 'secure_storage_service.dart';

class AndroidSecureStorage implements SecureStorageService {
  CredentialManager credentialManager = CredentialManager();

  @override
  Future<void> init() {
    if (credentialManager.isSupportedPlatform) {
      return credentialManager.init(preferImmediatelyAvailableCredentials: false);
    } else {
      throw Future.error(UnsupportedError("AndroidSecureStorage: CredentialManager is not supported on this platform"));
    }
  }

  @override
  Future<SecureStorageEntry?> read(String? key) {
    return credentialManager.getPasswordCredentials().then(_convert).then((value) {
      if (value == null) {
        return null;
      }
      if (value.key != key) {
        throw ArgumentError(CANNOT_VERIFY_BACKUP);
      }
      return value;
    });
  }

  @override
  Future<Iterable<String>> readAll() {
    return Future.value([]);
  }

  @override
  Future<void> write(SecureStorageEntry entry) {
    final credential = PasswordCredential(username: entry.key, password: entry.value);
    return credentialManager.savePasswordCredentials(credential);
  }

  @override
  Future<void> delete(String key) {
    return Future.value();
  }

  SecureStorageEntry? _convert(Credentials credential) {
    String? username = credential.passwordCredential?.username;
    String? password = credential.passwordCredential?.password;
    if (username == null || password == null) return null;
    return SecureStorageEntry(username, password);
  }
}
