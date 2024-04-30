import 'package:flutter/foundation.dart';
import 'package:silentshard/services/firebase_remote_config_service.dart';
import 'package:silentshard/utils.dart';

class AppUpdaterService extends ChangeNotifier {
  final Version _currentVersion;
  late Version _minimumAppVersionRequired;
  late Version _latestAppVersion;
  bool? forceUpdateApp;
  bool? updateAvailable;

  AppUpdaterService(this._currentVersion) {
    init();
  }

  Future<void> init() async {
    _latestAppVersion = Version(FirebaseRemoteConfigService().latestAppVersion);
    _minimumAppVersionRequired = Version(FirebaseRemoteConfigService().minimumAppVersionRequired);
    if (_currentVersion.compareTo(_minimumAppVersionRequired) < 0) {
      forceUpdateApp = true;
    } else {
      forceUpdateApp = false;
    }
    if (_currentVersion.compareTo(_latestAppVersion) < 0) {
      updateAvailable = true;
    } else {
      updateAvailable = false;
    }
    notifyListeners();
  }
}
