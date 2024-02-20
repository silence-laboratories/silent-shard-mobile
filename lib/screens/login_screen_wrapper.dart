// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/login_screen.dart';
import 'package:silentshard/screens/onboarding_screen.dart';
import 'package:silentshard/services/app_preferences.dart';

class LoginScreenWrapper extends StatelessWidget {
  const LoginScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, _) => appPreferences.getIsOnboardingCompleted() ? const LoginScreen() : OnboardingScreen(),
    );
  }
}
