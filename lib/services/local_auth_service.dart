import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuth extends ChangeNotifier {
  final _auth = LocalAuthentication();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> canAuthenticate() async => await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return false;

      bool res = await _auth.authenticate(
        localizedReason: 'Unlock',
      );
      _isAuthenticated = res;
      notifyListeners();
      return res;
    } catch (e) {
      debugPrint('error $e');
      return false;
    }
  }
}
