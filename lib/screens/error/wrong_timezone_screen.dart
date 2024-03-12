// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongTimezoneScreen extends StatelessWidget {
  final VoidCallback onPress;
  final VoidCallback onBack;
  const WrongTimezoneScreen({super.key, required this.onPress, required this.onBack});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorTitle: 'Oops! Incorrect Date and Time settings detected',
      errorSubtitle: Text(
        "Looks like the date and time settings in your device doesn't match your current timezone.\n\nPlease verify your date and time settings and try again.",
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      buttonTitle: 'Go to settings',
      onBack: onBack,
      onPressBottomButton: () {
        Navigator.of(context).pop();
        onPress();
      },
    );
  }
}
