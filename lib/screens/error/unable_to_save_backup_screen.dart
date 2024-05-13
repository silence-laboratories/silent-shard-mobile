// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/error/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class UnableToSaveBackupScreen extends StatelessWidget {
  final VoidCallback? onPressBottomButton;

  const UnableToSaveBackupScreen({super.key, this.onPressBottomButton});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorTitle: 'Uh-oh! Unable to save to ${Platform.isAndroid ? 'Google Password Manager' : 'iCloud Keychain'}',
      bottomWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make sure that Silent Shard is not denied in your Password Manager settings for all enabled Google accounts on your device.',
            style: textTheme.displaySmall,
          ),
          GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://silencelaboratories.com/snap/backup_error_android');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Text(
                "[See detailed instructions]",
                style: textTheme.headlineSmall,
              )),
          const Gap(10 * defaultSpacing)
        ],
      ),
      onPressBottomButton: onPressBottomButton,
    );
  }
}
