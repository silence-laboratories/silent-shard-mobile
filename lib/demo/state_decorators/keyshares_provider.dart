// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

import '../types/demo_decorator.dart';

class KeysharesProvider extends ChangeNotifier with DemoDecorator {
  final KeygenState _keygenState;
  Map<String, List<Keyshare>>? _demoKeyshares;

  Map<String, List<Keyshare>> get keyshares => _demoKeyshares ?? _keygenState.keysharesMap;

  KeysharesProvider(this._keygenState) {
    _keygenState.addListener(() => notifyListeners());
  }

  @override
  void startDemoMode() {
    super.startDemoMode();
    _demoKeyshares = {
      "metamask": [DemoKeyshare()]
    };
    notifyListeners();
  }

  @override
  void stopDemoMode() {
    super.stopDemoMode();
    _demoKeyshares = null;
    notifyListeners();
  }
}

class DemoKeyshare extends Keyshare {
  @override
  String get publicKey => "DemoPublicKey";

  @override
  Uint8List get publicKeyData => Uint8List(0);

  @override
  String get publicKeyHex => "DemoPublicKey";

  @override
  String get ethAddress => "0xDemoPublicKey";

  @override
  String toBytes() => "DemoKeyshare";

  @override
  void free() {}
}
