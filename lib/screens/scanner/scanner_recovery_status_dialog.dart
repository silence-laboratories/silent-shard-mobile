import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/backup_wallet/remind_enter_password_modal.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/components/loader.dart';
import 'package:silentshard/screens/scanner/scanner_screen.dart';
import 'package:silentshard/types/support_wallet.dart';

class ScannerRecoveryStatusDialog extends StatelessWidget {
  ScannerRecoveryStatusDialog(
      {super.key,
      required this.isSucceedWithNewAccount,
      required this.isSucceedWithPresentAccount,
      required this.isRecoverWithBackup,
      required this.showRemindEnterPassword,
      required this.isNotSucceed,
      this.walletInfo,
      required this.recoveryAddress,
      required this.toWalletScreenAfterRecovery});

  bool isSucceedWithNewAccount;
  bool isSucceedWithPresentAccount;
  bool isRecoverWithBackup;
  bool showRemindEnterPassword;
  bool isNotSucceed;
  SupportWallet? walletInfo;
  String recoveryAddress;
  Function toWalletScreenAfterRecovery;

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
              opacity: isNotSucceed ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Visibility(visible: isNotSucceed, child: RemindEnterPasswordModal(isScanning: true, walletName: walletInfo?.name ?? "")),
            )
          : AnimatedOpacity(
              opacity: isNotSucceed ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Wrap(children: [Loader(text: '${isRecoverWithBackup ? 'Recovering' : 'Re-Pairing'} with ${walletInfo?.name ?? ""}...')]),
            ),
    ]);
  }
}
