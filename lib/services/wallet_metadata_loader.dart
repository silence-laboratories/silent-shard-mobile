// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:silentshard/types/support_wallet.dart';

class WalletMetadataLoader {
  final Map<String, SupportWallet> _metadataMap = {};
  WalletMetadataLoader();

  SupportWallet getWalletMetadata(String walletId) {
    return _metadataMap[walletId] ?? SupportWallet.defaultWallet();
  }

  Future<void> loadWalletMetadata() async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getWalletMetadata');
      final results = await callable();
      final Map<String, dynamic> walletData = Map<String, dynamic>.from(results.data);
      for (final walletId in walletData.keys) {
        final walletMetadata = walletData[walletId];
        _metadataMap[walletId] = SupportWallet.fromJson(walletMetadata);
      }
    } catch (e) {
      throw Exception('Failed to load wallet metadata: $e');
    }
  }
}
