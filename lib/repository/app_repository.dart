// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:async/async.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:silentshard/demo/state_decorators/backups_provider.dart';
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
    addChild(backupsProvider);
  }

  // --- SDK wrappers ----

  late final pairingDataProvider = PairingDataProvider(_sdk.pairingState, _sdk.sodium);

  late final keysharesProvider = KeysharesProvider(_sdk.keygenState);

  late final backupsProvider = BackupsProvider(_sdk.backupState);

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

  Future<Keyshare> keygen(String walletId, String userId, PairingData? pairingData) async {
    if (isDemoActive) {
      return keysharesProvider.keyshares["metamask"]!.first as DemoKeyshare;
    }

    try {
      if (pairingData == null) {
        throw Exception("Pairing data is null while starting keygen.");
      }
      _analyticManager.trackDistributedKeyGen(wallet: walletId, type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.initiated);
      final keyshare = await _sdk.startKeygen(walletId, userId, pairingData).value;
      if (walletId == METAMASK_WALLET_ID) {
        await _sdk.fetchRemoteBackup(keyshare.ethAddress, userId).value;
      }
      _analyticManager.trackDistributedKeyGen(
          wallet: walletId, type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.success, address: keyshare.ethAddress);
      return keyshare;
    } catch (error) {
      _analyticManager.trackDistributedKeyGen(
          wallet: walletId, type: DistributedKeyGenType.new_account, status: DistributedKeyGenStatus.failed, error: error.toString());
      rethrow;
    }
  }

  Stream<BackupMessage> listenRemoteBackupMessage({required String userId}) {
    if (isDemoActive) {
      return CancelableCompleter<BackupMessage>().operation.asStream();
    }

    return _sdk.listenRemoteBackup(userId);
  }

  CancelableOperation<PairingData> _pair(QRMessage qrMessage, String userId, [WalletBackup? backup]) {
    return _sdk.startPairing(qrMessage, userId, backup);
  }

  CancelableOperation<PairingData?> repair(QRMessage qrMessage, String address, String userId) {
    if (isDemoActive) {
      return CancelableOperation.fromValue((null));
    }
    return _sdk.startRePairing(qrMessage, address, userId);
  }

  CancelableOperation<AppBackup> appBackup(String walletId, String address) {
    if (isDemoActive) {
      final demoBackup = WalletBackup([AccountBackup("0xDemoAddress", 'Test demo wallet', 'This is a demo backup, not recoverable')]);
      return CancelableOperation.fromValue(AppBackup(demoBackup, "metamask"));
    }

    return _sdk //
        .walletBackup(walletId, address)
        .then((walletBackup) => AppBackup(walletBackup, walletId));
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

  void remove(String walletId, String address) {
    stopDemoMode();
    _sdk.remove(walletId, address);
  }

  void deleteBackup(String walletId, String address) {
    _sdk.deleteBackup(walletId, address);
  }

  void updateMessagingToken(String userId, String token) => _sdk.updateMessagingToken(userId, token);
}
