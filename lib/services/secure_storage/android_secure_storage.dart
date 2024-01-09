import 'package:credential_manager/credential_manager.dart';

import 'secure_storage_service.dart';

class AndroidSecureStorage implements SecureStorageService {
  CredentialManager credentialManager = CredentialManager();

  @override
  Future<void> init() {
    return credentialManager.init(preferImmediatelyAvailableCredentials: false);
  }

  @override
  Future<SecureStorageEntry?> read(String? key) {
    if (key != null) return Future.error(ArgumentError("AndroidSecureStorage: key must be null"));
    return credentialManager.getPasswordCredentials().then(_convert);
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

  SecureStorageEntry? _convert(PasswordCredential credential) {
    if (credential.username == null || credential.password == null) return null;
    return SecureStorageEntry(credential.username!, credential.password!);
  }
}
