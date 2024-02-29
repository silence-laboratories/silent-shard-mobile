// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class NoBackupFoundWhileRepairingScreen extends StatelessWidget {
  final VoidCallback onPress;
  const NoBackupFoundWhileRepairingScreen({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ErrorHandler(
      onBack: onPress,
      errorTitle: 'Uh oh! No backup file found',
      errorSubtitle: Text(
        'Looks like your Browser is looking to restore a wallet and you are trying to create a new account.\nTry recovering from a backup file instead',
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
