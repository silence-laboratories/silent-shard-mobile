// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:dio/dio.dart';
import 'package:silentshard/firebase_options.dart';
import 'package:silentshard/types/support_wallet.dart';

class WalletMetadataLoader {
  final Map<String, SupportWallet> _metadataMap = {};
  WalletMetadataLoader();

  SupportWallet getWalletMetadata(String walletId) {
    return _metadataMap[walletId] ?? SupportWallet.defaultWallet();
  }

  Future<void> loadWalletMetadata() async {
    final dio = Dio();
    final response = await dio.get('https://us-central1-${DefaultFirebaseOptions.currentPlatform.projectId}.cloudfunctions.net/getWalletMetadata');
    final walletMetadata = response.data['response'] as Map<String, dynamic>;
    for (var walletId in walletMetadata.keys) {
      final walletJson = walletMetadata[walletId] as Map<String, dynamic>;
      _metadataMap[walletId] = SupportWallet(name: walletJson['name'], icon: walletJson['iconUrl']);
    }
  }
}
