import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../constants.dart';
import '../components/PaddedContainer.dart';
import '../components/backup_status_dashboard.dart';
import 'wallet_menu.dart';

class WalletCard extends StatelessWidget {
  final VoidCallback onRepair;
  final VoidCallback onLogout;
  final VoidCallback onExport;
  final String address;
  final VoidCallback onCopy;

  const WalletCard({
    super.key,
    required this.onRepair,
    required this.onLogout,
    required this.onExport,
    required this.address,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: secondaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          WalletInfo(widget: this),
          const Gap(0.5 * defaultPadding),
          const Divider(),
          BackupStatusDashboard(address: address),
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
    return Row(
      children: [
        PaddedContainer(
            child: Image.asset(
          'assets/images/walletLightFill.png',
          height: 27.6,
        )),
        const Gap(defaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                '${widget.address.substring(0, 5)}...${widget.address.substring(widget.address.length - 5)}',
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(defaultPadding),
              GestureDetector(
                onTap: widget.onCopy,
                child: Image.asset(
                  'assets/images/copyLight.png',
                  height: 20,
                ),
              ),
            ]),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/metamaskIcon.png',
                  height: 18,
                ),
                const Gap(defaultPadding),
                Text(
                  'MetaMask',
                  style: textTheme.displaySmall?.copyWith(fontSize: 12),
                )
              ],
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
