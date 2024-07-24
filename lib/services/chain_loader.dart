// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:silentshard/screens/sign/sign_request_view_model.dart';

class ChainLoader {
  final Map<int, Chain> _chainMap = {};

  ChainLoader();

  Future<Chain> getChainInfo(int? chainId) async {
    if (_chainMap.isEmpty) {
      await _loadChainsAndGenerate();
    }
    if (_chainMap[chainId] == null) {
      return Future.value(Chain(id: chainId ?? -1, name: 'Unknown', code: 'Unknown'));
    }
    return Future.value(_chainMap[chainId]);
  }

  Future<void> _loadChainsAndGenerate() async {
    var jsonString = await rootBundle.loadString("assets/json/chain.json");
    List<dynamic> chainListJson = json.decode(jsonString);

    for (var chainJson in chainListJson) {
      if (chainJson is Map<String, dynamic>) {
        final chain = Chain.fromJson(chainJson);
        _chainMap[chainJson['chainId']] = chain;
      }
    }
  }
}
