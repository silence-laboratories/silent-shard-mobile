import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._() : _remoteConfig = FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  static FirebaseRemoteConfigService? _instance;

  factory FirebaseRemoteConfigService() => _instance ??= FirebaseRemoteConfigService._();

  Future<void> _setConfigSettings() async => _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

  Future<void> _setDefaults() async => _remoteConfig.setDefaults(
        const {
          FirebaseRemoteConfigKeys.minimumSnapVersionRequired: '1.2.6',
          FirebaseRemoteConfigKeys.minimumAppVersionRequired: '1.2.0',
        },
      );

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    if (updated) {
      debugPrint('The config has been updated.');
    } else {
      debugPrint('The config is not updated..');
    }
  }

  Future<void> initialize() async {
    await _setConfigSettings();
    await _setDefaults();
    await fetchAndActivate();
  }

  String get minimumSnapVersionRequired => _remoteConfig.getString(FirebaseRemoteConfigKeys.minimumSnapVersionRequired);
  String get minimumAppVersionRequired => _remoteConfig.getString(FirebaseRemoteConfigKeys.minimumAppVersionRequired);
}

class FirebaseRemoteConfigKeys {
  static const String minimumSnapVersionRequired = 'minimumSnapVersionRequired';
  static const String minimumAppVersionRequired = 'minimumAppVersionRequired';
}
