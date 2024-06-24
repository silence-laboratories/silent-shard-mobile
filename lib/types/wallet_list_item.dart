// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

class WalletListItem {
  WalletListItem({
    required this.walletId,
    required this.address,
  });

  final String walletId;
  final String address;

  factory WalletListItem.fromJson(Map<String, dynamic> json) => WalletListItem(
        walletId: json["walletId"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "walletId": walletId,
        "address": address,
      };
}
