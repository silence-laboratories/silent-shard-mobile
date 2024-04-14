// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants.dart';
import '../components/padded_container.dart';
import '../../services/backup_service.dart';

typedef BackupSourcePickerCallback = void Function(BackupSource);

class BackupSourcePicker extends StatelessWidget {
  final BackupSourcePickerCallback onSelected;

  const BackupSourcePicker({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Restore using",
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(defaultSpacing * 5),
              BackupSourceItem(
                title: Platform.isIOS ? 'iCloud Keychain' : 'Google Password Manager',
                icon: Platform.isIOS
                    ? const Icon(Icons.apple)
                    : Image.asset(
                        'assets/images/googleIcon.png',
                        height: 20,
                      ),
                onSelected: () => onSelected(BackupSource.secureStorage),
              ),
              const Gap(defaultSpacing * 3),
              BackupSourceItem(
                title: "Choose Backup File",
                subtitle: TextSpan(
                  text: "Note: Select the file named as ",
                  style: textTheme.displaySmall,
                  children: [
                    TextSpan(
                      text: "'<address>-<date>-",
                      style: textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: "silentshard-wallet-backup.txt",
                      style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: "'.",
                      style: textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                icon: const Icon(Icons.folder),
                onSelected: () => onSelected(BackupSource.fileSystem),
              ),
              const Gap(defaultSpacing * 6),
            ],
          ),
        )
      ],
    );
  }
}

class BackupSourceItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final TextSpan? subtitle;
  final VoidCallback onSelected;

  const BackupSourceItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected,
        child: Row(children: [
          PaddedContainer(
            color: secondaryColor,
            child: icon,
          ),
          const Gap(defaultSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const Gap(defaultSpacing),
                  RichText(text: subtitle!),
                ],
              ],
            ),
          ),
        ]));
  }
}
