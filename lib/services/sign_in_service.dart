// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:firebase_auth/firebase_auth.dart';

class SignInService {
  Future<UserCredential> signInAnonymous() async {
    final authResult = await FirebaseAuth.instance.signInAnonymously();
    return authResult;
  }
}
