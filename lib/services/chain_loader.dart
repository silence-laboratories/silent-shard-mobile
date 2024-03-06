import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:silentshard/screens/sign/sign_request_view_model.dart';

class ChainLoader {
  late List<dynamic> _chains;

  ChainLoader() {
    loadChains();
  }

  Future<void> loadChains() async {
    var jsonString = await rootBundle.loadString("assets/json/chain.json");
    _chains = json.decode(jsonString);
  }

  Chain? getChainInfo(int chainId) {
    Map<String, dynamic>? chainObj = _chains.firstWhere(
      (element) => element is Map<String, dynamic> && element['chainId'] == chainId,
      orElse: () => null,
    );
    return chainObj != null ? Chain.fromJson(chainObj) : null;
  }
}
