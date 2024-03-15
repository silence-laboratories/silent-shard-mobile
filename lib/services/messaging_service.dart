// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../repository/app_repository.dart';
import '../auth_state.dart';

class MessagingService {
  final AuthState _authState;
  final AppRepository _appRepository;
  String? _token;

  StreamSubscription<String>? _tokenSubscription;

  MessagingService(this._authState, this._appRepository);

  void start() async {
    try {
      _token = await FirebaseMessaging.instance.getToken();
      _uploadToken(_token);
    } catch (error) {
      _handleError(error);
    }

    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(_uploadToken, onError: _handleError);

    _authState.addListener(_authListener);
  }

  void cancel() {
    _tokenSubscription?.cancel();
    _authState.removeListener(_authListener);
  }

  void _handleError(error) {
    FirebaseCrashlytics.instance.log('Error fetching messaging token: $error');
  }

  void _authListener() {
    _uploadToken(_token);
  }

  void _uploadToken(String? token) {
    final currentUserId = _authState.user?.uid;
    if (token == null || currentUserId == null) return;

    _token = token;
    _appRepository.updateMessagingToken(currentUserId, token);
  }
}
