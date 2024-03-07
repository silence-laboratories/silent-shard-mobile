import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:silentshard/screens/sign/sign_request_view_model.dart';

class ChainLoader {
  final Map<int, Chain> _chainMap = {};

  ChainLoader();

  Chain? getChainInfo(int chainId) {
    if (_chainMap.isEmpty) {
      _loadChainsAndGenerate();
      return _chainMap[chainId];
    }
    return _chainMap[chainId];
  }

  void _loadChainsAndGenerate() async {
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
