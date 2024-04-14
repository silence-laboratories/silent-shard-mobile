// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/screens/components/custom_popup_menu_divider.dart';

import '../../constants.dart';
import '../components/padded_container.dart';

enum WalletActions { repair, exportBackup, removeWallet }

class WalletMenu extends StatelessWidget {
  final PopupMenuItemSelected<WalletActions> onSelected;

  const WalletMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopupMenuButton<WalletActions>(
      initialValue: null,
      onSelected: onSelected,
      color: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF434E61)),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, defaultSpacing),
      itemBuilder: (BuildContext context) => _buildOptionsMenu(textTheme),
      child: const PaddedContainer(
        child: Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  List<PopupMenuEntry<WalletActions>> _buildOptionsMenu(TextTheme textTheme) => [
        PopupMenuItem<WalletActions>(
          value: WalletActions.repair,
          child: WalletOption(
            title: Flexible(
              child: Text(
                "Re-pair with browser",
                style: textTheme.displaySmall,
              ),
            ),
            icon: PaddedContainer(
                color: backgroundSecondaryColor2,
                child: Image.asset(
                  'assets/images/repeat.png',
                  width: 16,
                  height: 16,
                )),
          ),
        ),
        const CustomPopupMenuDivider(endIndent: defaultSpacing * 2, indent: defaultSpacing * 2),
        PopupMenuItem<WalletActions>(
          value: WalletActions.exportBackup,
          child: WalletOption(
            title: Flexible(
              child: Text(
                "Backup and export wallet",
                style: textTheme.displaySmall,
              ),
            ),
            icon: PaddedContainer(
                color: backgroundSecondaryColor2,
                child: Image.asset(
                  'assets/images/cloud-upload_light.png',
                  width: 16,
                )),
          ),
        ),
        const CustomPopupMenuDivider(endIndent: defaultSpacing * 2, indent: defaultSpacing * 2),
        PopupMenuItem<WalletActions>(
          value: WalletActions.removeWallet,
          child: WalletOption(
            title: const Flexible(
              child: Text(
                "Un-pair account",
                style: TextStyle(color: errorColor),
              ),
            ),
            icon: PaddedContainer(
              color: errorColor.withOpacity(0.15),
              child: const Icon(
                Icons.remove_circle_outline,
                color: errorColor,
                size: 16,
              ),
            ),
          ),
        ),
      ];
}

class WalletOption extends StatelessWidget {
  final Widget icon;
  final Widget title;
  const WalletOption({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 2),
        child: Row(
          children: [
            icon,
            const Gap(defaultSpacing),
            title,
          ],
        ),
      ),
    );
  }
}
