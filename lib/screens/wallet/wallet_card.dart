// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/screens/components/copy_button.dart';
import 'package:silentshard/types/support_wallet.dart';
import '../../constants.dart';
import '../components/padded_container.dart';
import '../components/backup_status_dashboard.dart';
import 'wallet_menu.dart';

class WalletCard extends StatelessWidget {
  final VoidCallback onRepair;
  final VoidCallback onLogout;
  final VoidCallback onExport;
  final String address;
  final VoidCallback onCopy;
  final String walletId;

  const WalletCard({
    super.key,
    required this.onRepair,
    required this.onLogout,
    required this.onExport,
    required this.address,
    required this.onCopy,
    required this.walletId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultSpacing * 1.5),
      child: Column(
        children: [
          WalletInfo(widget: this),
          const Gap(0.5 * defaultSpacing),
          const Divider(),
          BackupStatusDashboard(address: address, walletId: walletId),
        ],
      ),
    );
  }
}

class WalletInfo extends StatelessWidget {
  final WalletCard widget;
  const WalletInfo({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    SupportWallet walletInfo = SupportWallet.fromJson(walletMetaData[widget.walletId] ?? {});
    return Row(
      children: [
        PaddedContainer(
            child: Image.asset(
          walletInfo.icon,
          height: 28,
        )),
        const Gap(defaultSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                '${widget.address.substring(0, 5)}...${widget.address.substring(widget.address.length - 5)}',
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(defaultSpacing),
              CopyButton(onCopy: () {
                widget.onCopy();
              }),
              const SizedBox(width: 24),
            ]),
            Text(
              walletInfo.name,
              style: textTheme.displaySmall?.copyWith(fontSize: 12),
            )
          ],
        ),
        const Spacer(),
        WalletMenu(onSelected: (WalletActions item) {
          if (item == WalletActions.repair) {
            widget.onRepair();
          } else if (item == WalletActions.exportBackup) {
            widget.onExport();
          } else if (item == WalletActions.removeWallet) {
            widget.onLogout();
          }
        }),
      ],
    );
  }
}
