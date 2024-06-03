// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.fromJson(Map<String, String> json) {
    return SupportWallet(
      name: json['name'] ?? 'Unknown',
      icon: json['icon'] ?? 'assets/images/walletLightFill.png',
    );
  }
}
