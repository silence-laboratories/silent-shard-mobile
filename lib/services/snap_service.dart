import 'dart:async';

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/utils.dart';

class SnapService extends ChangeNotifier {
  final AppRepository _appRepository;
  final Version _leastSnapVersionSupported;
  Version? _snapVersion;
  bool? forceUpdateSnap;
  bool _showSnapUpdateSuccessful = false;
  bool willShowSnapUpdateSuccessful = false;
  StreamSubscription<UserData>? _streamSubscription;

  Version? get snapVersion => _snapVersion;

  SnapService(this._appRepository, this._leastSnapVersionSupported) {
    init();
  }

  void init() {
    FirebaseAuth.instance.authStateChanges().listen(_authListener);
  }

  void _authListener(User? user) {
    if (user == null) return;
    _streamSubscription = _appRepository.snapVersionListner(user.uid).listen(_handleResponse, onError: _handleError, cancelOnError: true);
  }

  void _handleResponse(UserData event) {
    handleSnapVersionChange(event.snapVersion);
  }

  set showSnapUpdateSuccessful(bool value) {
    _showSnapUpdateSuccessful = value;
    notifyListeners();
  }

  bool get showSnapUpdateSuccessful => _showSnapUpdateSuccessful;

  Future<void> handleSnapVersionChange(String? snapVersion) async {
    if (snapVersion != null) {
      _snapVersion = Version(snapVersion);
      if (_snapVersion == null) {
        forceUpdateSnap = false;
        _streamSubscription?.cancel();
      } else if (_snapVersion!.compareTo(_leastSnapVersionSupported) < 0) {
        forceUpdateSnap = true;
        willShowSnapUpdateSuccessful = true;
      } else {
        forceUpdateSnap = false;
        showSnapUpdateSuccessful = willShowSnapUpdateSuccessful;
        _streamSubscription?.cancel();
      }

      notifyListeners();
    }
  }

  void cancel() {
    _streamSubscription?.cancel();
  }

  void _handleError(error) {
    FirebaseCrashlytics.instance.log('Error fetching messaging token: $error');
  }
}
