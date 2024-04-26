// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:credential_manager/credential_manager.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/screens/backup_wallet/know_more_modal.dart';
import 'package:silentshard/screens/backup_wallet/skip_backup_modal.dart';
import 'package:silentshard/screens/backup_wallet/remind_backup_dapp_modal.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/components/password_status_banner.dart';
import 'package:silentshard/screens/error/unable_to_save_backup_screen.dart';
import 'package:silentshard/screens/wallet/wallet_screen.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/services/backup_use_cases.dart';
import 'package:silentshard/utils.dart';

import '../error/error_handler.dart';

class BackupWalletScreen extends StatefulWidget {
  const BackupWalletScreen({super.key, required this.walletId});

  final String walletId;

  @override
  State<BackupWalletScreen> createState() => _BackupWalletScreenState();
}

class _BackupWalletScreenState extends State<BackupWalletScreen> {
  late Stream<BackupMessage> _backupMessageStream;
  bool _isRemoteBackedUpReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.walletId != "snap") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isRemoteBackedUpReady) {
          _showWaitingSetupDialog();
        }
      });
      final appRepository = Provider.of<AppRepository>(context, listen: false);
      final keyshareProvider = appRepository.keysharesProvider;
      final ethAddress = keyshareProvider.keyshares[widget.walletId]?.firstOrNull?.ethAddress;
      if (ethAddress != null) {
        _backupMessageStream = Provider.of<AppRepository>(context, listen: false)
            .listenRemoteBackupMessage(walletId: widget.walletId, accountAddress: ethAddress)
            .map((event) {
          setState(() {
            _isRemoteBackedUpReady = event.isBackedUp;
          });
          return event;
        });
      }
    }
  }

  void _showWaitingSetupDialog() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.white.withOpacity(0.15),
      showDragHandle: true,
      context: context,
      builder: (context) => const RemindBackupDappModal(),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: secondaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        content: Wrap(children: [
          Check(text: 'Backup successful!'),
        ]),
        insetPadding: EdgeInsets.all(defaultSpacing * 1.5),
      ),
    );
  }

  Future<void> _performBackup(BuildContext context) async {
    if (!_isRemoteBackedUpReady) {
      _showWaitingSetupDialog();
    } else {
      final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
      FirebaseCrashlytics.instance.log('Saving backup');
      try {
        await SaveBackupToStorageUseCase(context).execute(widget.walletId);
        FirebaseCrashlytics.instance.log('Backup saved');
        analyticManager.trackSaveBackupSystem(
          success: true,
          source: PageSource.onboarding,
        );

        // ignore: use_build_context_synchronously
        _showDialog(context);
        await Future.delayed(const Duration(seconds: 2), () {});
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        FirebaseCrashlytics.instance.log('Error in saving backup: $error, ${parseCredentialExceptionMessage(error)}');
        if (error is CredentialException && error.code == 301) {
          return;
        }
        if (error is CredentialException && error.code == 302) {
          if (context.mounted) {
            _showUnableToSaveBackupScreen(context);
          }
        } else if (context.mounted) {
          _showErrorScreen(context);
        }
        analyticManager.trackSaveBackupSystem(
          success: false,
          source: PageSource.onboarding,
          error: parseCredentialExceptionMessage(error),
        );
      }
    }
  }

  void _showUnableToSaveBackupScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnableToSaveBackupScreen(
          onPressBottomButton: () {
            Navigator.pop(context);
            _performBackup(context);
          },
        ),
      ),
    );
  }

  void _showErrorScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorHandler(
          onPressBottomButton: () {
            Navigator.pop(context);
            _performBackup(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.all(defaultSpacing * 1.5),
          margin: const EdgeInsets.only(top: 0.5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Backup wallet",
              style: textTheme.displayLarge,
            ),
            const Gap(defaultSpacing * 2),
            Text(
              "Secure your wallet by backing up in ${Platform.isIOS ? 'iCloud Keychain' : 'Google Password Manager'}",
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultSpacing * 3),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: secondaryColor, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.all(defaultSpacing * 2),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: Platform.isIOS
                          ? Image.asset('assets/images/iCloudKeychain.png', width: MediaQuery.of(context).size.width * 0.66)
                          : Lottie.asset('assets/lottie/GPMAnimation.json'),
                    ),
                    Bullet(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Clicking ', style: textTheme.displaySmall),
                            TextSpan(text: '“Backup Wallet”', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text: ' triggers ${Platform.isIOS ? 'iCloud Keychain' : 'Google Password Manager as shown in image.'}',
                              style: textTheme.displaySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (Platform.isAndroid)
                      Bullet(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Just tap ', style: textTheme.displaySmall),
                              TextSpan(text: '“Save Password”', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' to complete backup.', style: textTheme.displaySmall),
                            ],
                          ),
                        ),
                      ),
                    if (Platform.isAndroid)
                      Row(children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            analyticManager.trackInfoSheet(PageSource.onboarding_backup);
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.black,
                              barrierColor: Colors.white.withOpacity(0.15),
                              showDragHandle: true,
                              context: context,
                              builder: (context) => const BackupKnowMoreModal(),
                            );
                          },
                          child: Text(
                            'Know more',
                            style: textTheme.headlineSmall,
                          ),
                        ),
                      ])
                  ]),
                ),
              ),
            ),
            const Gap(defaultSpacing * 2),
            if (widget.walletId != "snap")
              StreamBuilder(
                  stream: _backupMessageStream,
                  builder: (ctx, snapshot) {
                    bool isBackedUp = snapshot.data?.isBackedUp ?? false;
                    return isBackedUp
                        ? const PasswordStatusBanner(status: PasswordBannerStatus.ready)
                        : const PasswordStatusBanner(status: PasswordBannerStatus.warn);
                  }),
            const Gap(defaultSpacing * 2),
            Button(
              onPressed: () => _performBackup(context),
              child: Text('Backup wallet now', style: textTheme.displayMedium),
            ),
            const Gap(defaultSpacing),
            Center(
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    barrierColor: Colors.white.withOpacity(0.15),
                    showDragHandle: true,
                    context: context,
                    builder: (context) => Wrap(
                      children: [
                        BackupSkipWarning(onContinue: () {
                          analyticManager.trackSaveBackupSystem(
                            success: false,
                            source: PageSource.onboarding,
                            error: "User skipped backup",
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletScreen(),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
                child: Text('Skip for now (Not recommended)', style: textTheme.displayMedium?.copyWith(color: errorColor)),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

// 