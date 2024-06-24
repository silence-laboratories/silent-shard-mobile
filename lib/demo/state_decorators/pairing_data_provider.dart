// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:typed_data';

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:flutter/material.dart';
import 'package:sodium/sodium.dart';

import '../types/demo_decorator.dart';

class PairingDataProvider extends ChangeNotifier with DemoDecorator {
  final Sodium _sodium;
  final PairingState _pairingState;
  DemoPairingData? _demoPairingData;

  PairingData? get pairingData => _demoPairingData ?? _pairingState.pairingDataMap["DemoAddress"];

  PairingDataProvider(this._pairingState, this._sodium) {
    _pairingState.addListener(() => notifyListeners());
  }

  @override
  void startDemoMode() {
    super.startDemoMode();
    _demoPairingData = DemoPairingData(_sodium);
    notifyListeners();
  }

  @override
  void stopDemoMode() {
    super.stopDemoMode();
    _demoPairingData = null;
    notifyListeners();
  }
}

class DemoPairingData extends PairingData {
  DemoPairingData(Sodium sodium)
      : super(
          "DemoPairingId",
          Uint8List(0),
          sodium.crypto.box.keyPair(),
          null,
        );
}
