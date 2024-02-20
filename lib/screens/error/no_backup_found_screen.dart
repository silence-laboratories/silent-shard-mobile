// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class NoBackupFoundScreen extends StatelessWidget {
  final VoidCallback? onPressBottomButton;

  const NoBackupFoundScreen({super.key, this.onPressBottomButton});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorTitle: 'No backup file found in your ${Platform.isAndroid ? 'Google Password Manager' : 'iCloud Keychain'}',
      bottomWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You may try these steps:',
            style: textTheme.bodyMedium,
          ),
          const Gap(defaultPadding),
          Bullet(
              child: Text(
            'Check for any exported backup files.',
            style: textTheme.bodyMedium,
          )),
          Bullet(
              child: Text(
            'Add any other ${Platform.isAndroid ? 'Google' : 'iCloud'} accounts previously used on this device and try again.',
            style: textTheme.bodyMedium,
          )),
          const Gap(defaultPadding * 4),
        ],
      ),
      onPressBottomButton: onPressBottomButton,
    );
  }
}
