import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends ChangeNotifier {
  StreamSubscription<User?>? _authSubscription;
  User? _user;

  User? get user => _user;

  AuthState() {
    startListening();
  }

  void startListening() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(handleUserChange);
    handleUserChange(FirebaseAuth.instance.currentUser);
  }

  void stopListening() {
    _authSubscription?.cancel();
  }

  void handleUserChange(User? user) {
    _user = user;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
