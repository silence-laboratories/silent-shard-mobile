// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';

enum BackupBannerStatus { warn, alert, ready }

class BackupStatusBanner extends StatelessWidget {
  const BackupStatusBanner({super.key, required this.status, this.isMetaMaskBackup = false});

  final BackupBannerStatus status;
  final bool isMetaMaskBackup;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      BackupBannerStatus.warn => const Icon(Icons.info, color: Color(0xfffdd147)),
      BackupBannerStatus.alert => const Icon(Icons.error, color: Color(0xffF87171)),
      BackupBannerStatus.ready => const Icon(Icons.check_circle, color: Color(0xff4ADE80)),
    };

    final text = switch (status) {
      BackupBannerStatus.warn => const Text('Password not set on dApp', style: TextStyle(color: Color(0xFFFEE28A))),
      BackupBannerStatus.alert =>
        Text(isMetaMaskBackup ? 'Couldn’t fetch backup. Retry' : 'Password not set on dApp', style: const TextStyle(color: Color(0xFFFECACA))),
      BackupBannerStatus.ready => Text(isMetaMaskBackup ? 'Backup fetched' : 'Password set on dApp', style: const TextStyle(color: Color(0xFFBBF7D1)))
    };

    final border = switch (status) {
      BackupBannerStatus.warn => Border.all(color: const Color(0xFF85680E), width: 1.0),
      BackupBannerStatus.alert => Border.all(color: const Color(0xFF991B1B), width: 1.0),
      BackupBannerStatus.ready => Border.all(color: const Color(0xFF166533), width: 1.0),
    };

    final bgColor = switch (status) {
      BackupBannerStatus.warn => const Color.fromRGBO(253, 209, 71, 0.10),
      BackupBannerStatus.alert => const Color.fromRGBO(248, 113, 113, 0.10),
      BackupBannerStatus.ready => const Color.fromRGBO(74, 222, 128, 0.10),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
        border: border,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          icon,
          const Gap(defaultSpacing / 2),
          text,
          if (status == BackupBannerStatus.alert) //
            ...[
            const Spacer(),
            const Icon(Icons.arrow_forward, color: Color(0xffF87171)),
          ]
        ],
      ),
    );
  }
}
