import 'package:flutter/foundation.dart';
import 'package:silentshard/services/firebase_remote_config_service.dart';
import 'package:silentshard/utils.dart';

class AppUpdaterService extends ChangeNotifier {
  final Version _currentVersion;
  bool? forceUpdateApp;
  bool? updateAvailable;

  AppUpdaterService(this._currentVersion) {
    init();
  }

  Future<void> init() async {
    final minimumAppVersionRequired = Version(FirebaseRemoteConfigService().minimumAppVersionRequired);
    if (_currentVersion.compareTo(minimumAppVersionRequired) < 0) {
      forceUpdateApp = true;
    } else {
      forceUpdateApp = false;
    }
    notifyListeners();
  }
}
