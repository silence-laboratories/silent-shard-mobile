// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

class Chain {
  final int id;
  final String name;
  final String code;

  Chain({required this.id, required this.name, required this.code});

  factory Chain.fromJson(Map<String, dynamic> json) {
    return Chain(
      id: json['chainId'] as int,
      name: json['name'] as String,
      code: json['chain'] as String,
    );
  }
}

class SignRequestViewModel {
  static final oneEth = BigInt.from(10).pow(18);

  final SignRequest signRequest;

  late final Future<Chain> _chain;

  Future<Chain> get chain => _chain;

  SignRequestViewModel(this.signRequest, this._chain);

  String get displayMessage => signRequest.readableMessage;

  String? get recipient => signRequest.to;

  SignType get signType => signRequest.signType;

  String? get amount {
    if (signRequest.value == null) return null;

    final whole = signRequest.value! ~/ oneEth;
    final remainder = signRequest.value!.remainder(oneEth);
    final fraction = remainder / oneEth;

    return whole.toString() + fraction.toString().substring(1);
  }

  String get createdAt => signRequest.createdAt.toString();
}
