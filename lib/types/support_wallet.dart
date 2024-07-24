// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.defaultWallet() {
    return SupportWallet(
      name: 'Unknown',
      icon: 'assets/images/walletLightFill.png',
    );
  }

  factory SupportWallet.fromJson(dynamic json) {
    return SupportWallet(
      name: json['name'] ?? 'Unknown',
      icon: json['iconUrl'] ?? 'assets/images/walletLightFill.png',
    );
  }
}
