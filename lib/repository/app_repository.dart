// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:async/async.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:silentshard/third_party/analytics.dart';

import '../types/app_backup.dart';
import '../demo/types/demo_decorator_composite.dart';
import '../demo/state_decorators/pairing_data_provider.dart';
import '../demo/state_decorators/keyshares_provider.dart';

class AppRepository extends DemoDecoratorComposite {
  final Dart2PartySDK _sdk;
  final AnalyticManager _analyticManager;

  AppRepository(this._sdk, this._analyticManager) {
    addChild(pairingDataProvider);
    addChild(keysharesProvider);
  }

  // --- SDK wrappers ----

  late final pairingDataProvider = PairingDataProvider(_sdk.pairingState, _sdk.sodium);

  late final keysharesProvider = KeysharesProvider(_sdk.keygenState);

  CancelableOperation<PairingData?> pair(QRMessage qrMessage, String userId, WalletBackup? backup) {
    if (qrMessage.isDemo) {
      startDemoMode();
      return CancelableOperation.fromValue((null));
    }

    if (backup != null) {
      return _pair(qrMessage, userId, backup);
    } else {
      return _pair(qrMessage, userId);
    }
  }

  Future<Keyshare2> keygen(String walletId) async {
    try {
      _analyticManager.trackDistributedKeyGen(type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.initiated);
      final keyshare = await _sdk.startKeygen(walletId).value;
      _analyticManager.trackDistributedKeyGen(
          type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.success, publicKey: keyshare.ethAddress);
      return keyshare;
    } catch (error) {
      _analyticManager.trackDistributedKeyGen(
          type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.failed, error: error.toString());
      rethrow;
    }
  }

  Stream<BackupMessage> listenRemoteBackupMessage({required String walletId, required String accountAddress}) {
    if (isDemoActive) {
      return CancelableCompleter<BackupMessage>().operation.asStream();
    }

    return _sdk.listenRemoteBackup(walletId: walletId, accountAddress);
  }

  CancelableOperation<PairingData> _pair(QRMessage qrMessage, String userId, [WalletBackup? backup]) {
    _sdk.reset();
    return _sdk.startPairing(qrMessage, userId, backup);
  }

  CancelableOperation<PairingData?> repair(QRMessage qrMessage, String userId) {
    if (isDemoActive) {
      return CancelableOperation.fromValue((null));
    }

    return _sdk.startRePairing(qrMessage, userId);
  }

  CancelableOperation<AppBackup> appBackup(String walletId) {
    if (isDemoActive) {
      final demoBackup = WalletBackup([AccountBackup("0xDemoAddress", 'Test demo wallet', 'This is a demo backup, not recoverable')]);
      return CancelableOperation.fromValue(AppBackup(demoBackup));
    }

    return _sdk //
        .walletBackup(walletId)
        .then((walletBackup) => AppBackup(walletBackup));
  }

  Stream<SignRequest> signRequests() {
    if (isDemoActive) {
      return CancelableCompleter<SignRequest>().operation.asStream();
    }

    return _sdk.signRequests();
  }

  CancelableOperation<String> approve(SignRequest request) {
    if (isDemoActive) return CancelableOperation.fromValue("DemoSignature");

    return _sdk.approve(request);
  }

  void decline(SignRequest request) {
    if (isDemoActive) return;
    _sdk.decline(request);
  }

  void reset() {
    stopDemoMode();
    _sdk.reset();
  }

  void updateMessagingToken(String userId, String token) => _sdk.updateMessagingToken(userId, token);
}
