import 'package:flutter/foundation.dart';

class WalletHighlightProvider with ChangeNotifier {
  String _address = '';
  bool _isScrolled = false;

  String get pairedAddress => _address;

  bool get scrolled => _isScrolled;

  void setPairedAddress(String newValue) {
    _address = newValue;
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
