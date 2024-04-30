// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:async/async.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:dart_2_party_ecdsa/src/types/user_data.dart';
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
      return _pair(qrMessage, userId).then((pairingData) async {
        final keyshare = await _keygen(userId);
        final ethAddress = keyshare.ethAddress;
        return (ethAddress, pairingData);
      }).then((_) {
        String ethAddress = _.$1;
        PairingData pairingData = _.$2;
        _sdk.fetchRemoteBackup(ethAddress, userId).value;
        return pairingData;
      });
    }
  }

  Future<Keyshare2> _keygen(String userId) async {
    try {
      _analyticManager.trackDistributedKeyGen(type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.initiated);
      final keyshare = await _sdk.startKeygen(userId).value;
      _analyticManager.trackDistributedKeyGen(
          type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.success, publicKey: keyshare.ethAddress);
      return keyshare;
    } catch (error) {
      _analyticManager.trackDistributedKeyGen(
          type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.failed, error: error.toString());
      rethrow;
    }
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

  CancelableOperation<AppBackup> appBackup() {
    if (isDemoActive) {
      final demoBackup = WalletBackup([AccountBackup("0xDemoAddress", 'Test demo wallet', 'This is a demo backup, not recoverable')]);
      return CancelableOperation.fromValue(AppBackup(demoBackup));
    }

    return _sdk //
        .walletBackup()
        .then((walletBackup) => AppBackup(walletBackup));
  }

  Stream<UserData> snapVersionListner(String userId) {
    return _sdk.snapVersionListener(userId);
  }

  Stream<SignRequest> signRequests(String userId) {
    if (isDemoActive) {
      return CancelableCompleter<SignRequest>().operation.asStream();
    }

    return _sdk.signRequests(userId);
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
