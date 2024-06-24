// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class NewBackupFoundScreen extends StatelessWidget {
  const NewBackupFoundScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.all(defaultSpacing * 1.5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(defaultSpacing * 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/newBackupFound.png',
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'New backup found!',
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'Your app has successfully fetched the right backup and is ready to backup!',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Column(
                                children: [
                                  Bullet(
                                      child: Text(
                                    Platform.isAndroid
                                        ? 'Your old backup will be updated to the new one if saved to google password manager.'
                                        : 'Your old backup will be updated to the new one if saved to keychain.',
                                    style: textTheme.displaySmall,
                                  )),
                                  Bullet(
                                      child: RichText(
                                          text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'If you had exported the previous backup to a file, make sure you delete the file ',
                                          style: textTheme.displaySmall),
                                      TextSpan(
                                          text: '<address>-<date>-',
                                          style: textTheme.displaySmall?.copyWith(
                                            fontStyle: FontStyle.italic,
                                          )),
                                      TextSpan(
                                          text: 'silentshard-wallet-backup.txt',
                                          style: textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                    ],
                                  ))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(defaultSpacing * 2),
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinue();
                        },
                        child: Text(
                          'Continue',
                          style: textTheme.displaySmall?.copyWith(height: 2),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
