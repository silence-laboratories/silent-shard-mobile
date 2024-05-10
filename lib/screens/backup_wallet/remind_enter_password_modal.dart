// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class RemindEnterPasswordModal extends StatelessWidget {
  const RemindEnterPasswordModal({
    super.key,
    required this.walletName,
    this.isScanning = false,
  });

  final String walletName;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Gap(defaultSpacing),
            Text(
              'Please ${isScanning == true ? "enter" : "set"} a Password for your $walletName wallet on Desktop',
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
                      "Waiting for password setup on Desktop to unlock Backup options",
                      style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(defaultSpacing),
                    Text(
                      isScanning == true
                          ? "Waiting for password on Desktop to complete your recovery"
                          : "This password will be used when recovering this wallet on your Browser/Desktop.",
                      style: textTheme.bodySmall,
                    ),
                  ],
                )),
            if (isScanning == false) ...[
              const Gap(defaultSpacing * 5),
              Button(
                onPressed: () => {Navigator.of(context).pop()},
                child: Text('Got it', style: textTheme.displayMedium),
              )
            ],
            const Gap(defaultSpacing * 3),
          ]),
        )
      ],
    );
  }
}
