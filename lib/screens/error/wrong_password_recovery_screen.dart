// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongPasswordRecoveryScreen extends StatelessWidget {
  final VoidCallback onPress;
  const WrongPasswordRecoveryScreen({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ErrorHandler(
      onBack: onPress,
      errorTitle: 'Uh oh! Looks like you are using the wrong password.',
      errorSubtitle: Text(
        'Your account is only recoverable with the correct password. Please try again.',
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      onPressBottomButton: () {
        Navigator.of(context).pop();
        onPress();
      },
    );
  }
}
