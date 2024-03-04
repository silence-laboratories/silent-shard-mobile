// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongMetaMaskWalletForRecoveryScreen extends StatelessWidget {
  final VoidCallback onPress;
  const WrongMetaMaskWalletForRecoveryScreen({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ErrorHandler(
      onBack: onPress,
      errorTitle: 'Uh oh! Looks like you are using the wrong MetaMask Wallet to recover your Snap account.',
      errorSubtitle: Text(
        'Your Snap account backup is only recoverable with the same MetaMask wallet it was created with.\n\nPlease try with a different MetaMask wallet.',
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
