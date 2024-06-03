// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class NotFetchBackupModal extends StatelessWidget {
  const NotFetchBackupModal({
    super.key,
    this.isBackupAvailable = false,
  });

  final bool isBackupAvailable;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    if (isBackupAvailable) {
      Navigator.of(context).pop();
    }
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Gap(defaultSpacing),
            Text(
              'Couldn’t fetch your backup',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(defaultSpacing * 2),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 2, vertical: defaultSpacing * 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111112),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF343A46),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/browserScreen.png',
                      ),
                    ),
                    const Gap(defaultSpacing * 4),
                    Text(
                      "Waiting for your browser backup",
                      style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(defaultSpacing),
                    Bullet(
                        child: Text(
                      'Head on over to your wallet DApp : snap.silencelaboratories.com.',
                      style: textTheme.bodySmall,
                    )),
                    Bullet(
                        child: Text(
                      'Click on the menu options of your wallet.',
                      style: textTheme.bodySmall,
                    )),
                    Bullet(
                        child: Text(
                      'Select the “Refresh backup” option.',
                      style: textTheme.bodySmall,
                    )),
                  ],
                )),
            const Gap(defaultSpacing * 5),
            Button(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('Got it', style: textTheme.displayMedium),
            ),
            const Gap(defaultSpacing * 3),
          ]),
        )
      ],
    );
  }
}
