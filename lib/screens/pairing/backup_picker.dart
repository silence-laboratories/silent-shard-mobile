// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants.dart';
import '../components/padded_container.dart';

typedef SelectionCallback = void Function(String);

class BackupPicker extends StatelessWidget {
  final Iterable<String> list;
  final SelectionCallback onSelected;

  const BackupPicker({super.key, required this.list, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 1,
      maxChildSize: 1,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(defaultSpacing * 2),
          child: Column(
            children: [
              Text(
                "iCloud Keychain",
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(defaultSpacing),
              Text(
                "Select any account to restore from your iCloud Keychain",
                style: textTheme.bodyMedium,
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 2 * defaultSpacing),
                      child: BackupItem(address: list.elementAt(index), onPressed: onSelected),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BackupItem extends StatelessWidget {
  final String address;
  final SelectionCallback onPressed;

  const BackupItem({super.key, required this.address, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultSpacing * 1.5,
          vertical: defaultSpacing * 2,
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(defaultSpacing),
          ),
        ),
      ),
      onPressed: () => onPressed(address),
      child: Row(
        children: [
          PaddedContainer(
            color: backgroundSecondaryColor2,
            child: Image.asset(
              "assets/images/walletLight.png",
              height: 20,
            ),
          ),
          const Gap(defaultSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: textTheme.displaySmall?.copyWith(height: 1.3),
                ),
                Text(
                  "● ● ● ● ● ● ● ●",
                  style: textTheme.bodyMedium?.copyWith(letterSpacing: -0.2),
                ),
                Text(
                  "Saved backup",
                  style: textTheme.bodyMedium?.copyWith(height: 1.7),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
