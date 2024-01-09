import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/Bullet.dart';
import 'package:silentshard/screens/components/Button.dart';
import 'package:silentshard/services/backup_use_cases.dart';

import 'error/error_handler.dart';

class BackupWalletScreen extends StatelessWidget {
  const BackupWalletScreen({super.key});

  Future<void> _performBackup(BuildContext context) async {
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);

    try {
      await SaveBackupToStorageUseCase(context).execute();
      analyticManager.trackSaveBackupSystem(
        success: true,
        source: PageSource.onboarding,
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (context.mounted) {
        _showErrorScreen(context);
      }
      debugPrint('error $error');
      analyticManager.trackSaveBackupSystem(
        success: false,
        source: PageSource.onboarding,
        error: error.toString(),
      );
    }
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
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          margin: const EdgeInsets.only(top: 0.5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Backup wallet",
              style: textTheme.displayLarge,
            ),
            const Gap(defaultPadding * 2),
            Text(
              "Secure your wallet by backing up in ${Platform.isIOS ? 'iCloud Keychain' : 'Google Password Manager'}",
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultPadding * 3),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: secondaryColor, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding * 2),
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
            const Gap(defaultPadding * 2),
            Button(
              onPressed: () => _performBackup(context),
              child: Text('Backup wallet now', style: textTheme.displayMedium),
            ),
            const Gap(defaultPadding),
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
                          int count = 0;
                          analyticManager.trackSaveBackupSystem(
                            success: false,
                            source: PageSource.onboarding,
                            error: "User skipped backup",
                          );
                          Navigator.of(context).popUntil((_) => count++ >= 2);
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

class BackupSkipWarning extends StatefulWidget {
  final VoidCallback onContinue;
  const BackupSkipWarning({super.key, required this.onContinue});

  @override
  State<BackupSkipWarning> createState() => _BackupSkipWarningState();
}

enum CheckBoxState { checked, unchecked }

class _BackupSkipWarningState extends State<BackupSkipWarning> {
  CheckBoxState _checkboxState = CheckBoxState.unchecked;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: defaultPadding * 2, right: defaultPadding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Are you sure?",
            style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(defaultPadding * 2),
          Center(
            child: Image.asset(
              'assets/images/warningYellow.png',
              height: 100,
            ),
          ),
          const Gap(defaultPadding * 2),
          Text(
            'Your wallet backup file is crucial for restoring your funds in case any of your phone or laptop device is lost or reset.',
            style: textTheme.bodyMedium,
          ),
          const Gap(defaultPadding * 2),
          const Divider(),
          Row(
            children: [
              Checkbox(
                value: _checkboxState == CheckBoxState.checked ? true : false,
                onChanged: (value) {
                  setState(() {
                    _checkboxState = (value ?? false) ? CheckBoxState.checked : CheckBoxState.unchecked;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'I understand the risk and agree to continue',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Gap(defaultPadding),
          Button(
              type: ButtonType.primary,
              buttonColor: primaryColor.withOpacity(_checkboxState == CheckBoxState.unchecked ? 0.5 : 1),
              onPressed: () {
                _checkboxState == CheckBoxState.unchecked ? null : widget.onContinue();
              },
              isDisabled: _checkboxState == CheckBoxState.unchecked,
              child: Text('Continue', style: textTheme.displayMedium))
        ]),
      ),
    );
  }
}

class BackupKnowMoreModal extends StatelessWidget {
  const BackupKnowMoreModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: defaultPadding * 2, right: defaultPadding * 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Gap(defaultPadding),
            Text(
              'Google Password Manager',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(defaultPadding * 2),
            Center(
              child: Lottie.asset('assets/lottie/GPMAnimation.json'),
            ),
            const BackupKnowMoreFAQ(
              question: 'Why am I saving a password?',
              answer: "The Silent Shard App leverages the your Google Password Manager to store your email id and your backup file.",
            ),
            const Gap(defaultPadding * 2),
            const BackupKnowMoreFAQ(
              question: 'What is Google Password Manager?',
              answer: "Google Password Manager is an android feature that securely saves passwords in your device storage.",
            ),
            const Gap(defaultPadding * 2),
            const BackupKnowMoreFAQ(
              question: 'What happens if I click on “Never”?',
              answer:
                  "Your backup will not be saved to your google password manager. You can still export the backup file to your device storage or any other password managers.",
            ),
            const Gap(defaultPadding * 6),
          ]),
        )
      ],
    );
  }
}

class BackupKnowMoreFAQ extends StatelessWidget {
  final String question;
  final String answer;
  const BackupKnowMoreFAQ({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        question,
        style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      const Gap(defaultPadding),
      Text(
        answer,
        style: textTheme.bodySmall,
      ),
    ]);
  }
}
