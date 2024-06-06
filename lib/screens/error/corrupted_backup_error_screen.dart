// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class CorruptedBackupErrorScreen extends StatelessWidget {
  const CorruptedBackupErrorScreen({super.key, required this.onContinue});

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
                                'assets/images/broken_backup.png',
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'Alert: Wrong backup detected',
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'Looks like the backup that you had saved was corrupted.',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Column(
                                children: [
                                  Bullet(
                                      child: RichText(
                                          text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Head over to ', style: textTheme.displaySmall),
                                      TextSpan(
                                          text: 'snap.silencelaboratories.com',
                                          style: textTheme.displaySmall?.copyWith(
                                            decoration: TextDecoration.underline,
                                          )),
                                      TextSpan(text: ' on your ', style: textTheme.displaySmall),
                                      TextSpan(text: 'Desktop Browser.', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ))),
                                  Bullet(
                                      child: RichText(
                                          text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Click on the ', style: textTheme.displaySmall),
                                      TextSpan(text: '“Update”', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' banner to update your Snap to the latest version.', style: textTheme.displaySmall),
                                    ],
                                  ))),
                                  Bullet(
                                      child: RichText(
                                          text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Backup your wallet', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' on this device using your desired method again.', style: textTheme.displaySmall),
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
                          onContinue();
                        },
                        child: Text(
                          'I understand',
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
