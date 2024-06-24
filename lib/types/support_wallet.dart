// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:silentshard/constants.dart';

class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.fromWalletId(String walletId) {
    final json = walletMetaData[walletId] ?? {};
    return SupportWallet(
      name: json['name'] ?? 'Unknown',
      icon: json['icon'] ?? 'assets/images/walletLightFill.png',
    );
  }
}
