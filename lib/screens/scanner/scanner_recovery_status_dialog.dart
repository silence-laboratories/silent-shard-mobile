// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/remind_enter_password_modal.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/components/loader.dart';
import 'package:silentshard/screens/scanner/scanner_screen.dart';
import 'package:silentshard/types/support_wallet.dart';

class ScannerRecoveryStatusDialog extends StatelessWidget {
  const ScannerRecoveryStatusDialog(
      {super.key,
      required this.isSucceedWithNewAccount,
      required this.isSucceedWithPresentAccount,
      required this.isRecoverWithBackup,
      required this.showRemindEnterPassword,
      required this.isInProgress,
      this.walletInfo,
      required this.recoveryAddress,
      required this.toWalletScreenAfterRecovery});

  final bool isSucceedWithNewAccount;
  final bool isSucceedWithPresentAccount;
  final bool isRecoverWithBackup;
  final bool showRemindEnterPassword;
  final bool isInProgress;
  final SupportWallet? walletInfo;
  final String recoveryAddress;
  final Function toWalletScreenAfterRecovery;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedOpacity(
        opacity: isSucceedWithNewAccount ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: Wrap(children: [Check(text: '${isRecoverWithBackup ? 'Recovering' : 'Re-Pairing'} successfully!')]),
      ),
      AnimatedOpacity(
        opacity: isSucceedWithPresentAccount ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: Visibility(
            visible: isSucceedWithPresentAccount,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Check(text: 'Account already present on App'),
              const Gap(defaultSpacing * 2),
              PopoverAddress(name: walletInfo?.name ?? "", icon: walletInfo?.icon ?? "", address: recoveryAddress),
              Button(
                onPressed: () {
                  toWalletScreenAfterRecovery();
                },
                child: Text('Continue', style: Theme.of(context).textTheme.displaySmall),
              ),
            ])),
      ),
      showRemindEnterPassword
          ? AnimatedOpacity(
              opacity: isInProgress ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Visibility(visible: isInProgress, child: RemindEnterPasswordModal(isScanning: true, walletName: walletInfo?.name ?? "")),
            )
          : AnimatedOpacity(
              opacity: isInProgress ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Wrap(children: [Loader(text: '${isRecoverWithBackup ? 'Recovering' : 'Re-Pairing'} with ${walletInfo?.name ?? ""}...')]),
            ),
    ]);
  }
}
