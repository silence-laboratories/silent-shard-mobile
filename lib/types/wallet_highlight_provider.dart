import 'package:flutter/foundation.dart';

class WalletHighlightProvider with ChangeNotifier {
  String _walletId = '';
  bool _isScrolled = false;

  String get pairedWalletId => _walletId;

  bool get scrolled => _isScrolled;

  void setPairedWalletId(String newValue) {
    _walletId = newValue;
    notifyListeners();
  }

  void setScrolled(bool isScrolled) {
    _isScrolled = isScrolled;
    notifyListeners();
  }

  void setScrolledTemporarily() async {
    _isScrolled = true;
    await Future.delayed(const Duration(seconds: 2));
    _isScrolled = false;
    notifyListeners();
  }
}
