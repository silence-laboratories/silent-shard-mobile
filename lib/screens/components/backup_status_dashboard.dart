// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../types/backup_info.dart';
import '../../services/backup_service.dart';
import '../backup_destination/backup_destination_screen.dart' show BackupDestinationScreen;

const iconHeight = 16.0;

extension BackupStatusUtils on BackupStatus {
  Color get tintColor => switch (this) {
        BackupStatus.pending => pendingColor,
        BackupStatus.done => doneColor,
        BackupStatus.missing => criticalColor,
      };

  Image get statusIcon => switch (this) {
        BackupStatus.pending => Image.asset("assets/images/time_light.png", height: iconHeight),
        BackupStatus.done => Image.asset("assets/images/checkmark-circle_light.png", height: iconHeight, color: doneIconColor),
        BackupStatus.missing => Image.asset("assets/images/checkmark-triangle_light.png", height: iconHeight, color: errorColor),
      };

  // String get statusDetails => switch (this) {
  //       BackupStatus.pending => "Action pending",
  //       BackupStatus.done => "Backup valid",
  //       BackupStatus.missing => "Backup not found. Backup now!",
  //     };
}

BackupCheck getBackupCheck(BackupInfo info, BackupSource source) =>
    switch (source) { BackupSource.fileSystem => info.file, BackupSource.secureStorage => info.cloud };

class StatusIndicator extends StatelessWidget {
  final BackupStatus status;
  final Image image;
  static const height = 24.0;

  const StatusIndicator({super.key, required this.status, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0.5 * defaultSpacing),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: status.tintColor),
        borderRadius: const BorderRadius.all(Radius.circular(0.5 * height)),
      ),
      child: Row(children: [
        image,
        const Gap(0.5 * defaultSpacing),
        status.statusIcon,
      ]),
    );
  }
}

class BackupStatusWidget extends StatelessWidget {
  final String address;
  final BackupSource source;
  final Image image;

  const BackupStatusWidget({
    super.key,
    required this.address,
    required this.source,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BackupService>(
      builder: (context, service, _) => Row(
        children: [
          StatusIndicator(
            status: getBackupCheck(service.getBackupInfo(address), source).status,
            image: image,
          ),
        ],
      ),
    );
  }
}

class BackupStatusDashboard extends StatelessWidget {
  final String address;
  final String walletName;

  const BackupStatusDashboard({super.key, required this.address, required this.walletName});

  void _showBackupDestination(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => BackupDestinationScreen(
                address: address,
                walletName: walletName,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showBackupDestination(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3 * defaultSpacing),
        child: Row(children: [
          const Gap(defaultSpacing),
          Row(children: [
            Image.asset(
              "assets/images/cloud-upload_light.png",
              height: iconHeight,
            ),
            const Gap(defaultSpacing),
            Text(
              "Backups",
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            )
          ]),
          const Gap(defaultSpacing * 1.5),
          BackupStatusWidget(
            address: address,
            source: BackupSource.secureStorage,
            image: Image.asset(
              "assets/images/social${Platform.isIOS ? "Apple" : "Google"}.png",
              height: iconHeight,
            ),
          ),
          const Gap(defaultSpacing * 1.5),
          BackupStatusWidget(
            address: address,
            source: BackupSource.fileSystem,
            image: Image.asset(
              "assets/images/folder-open_light.png",
              height: iconHeight,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded)
        ]),
      ),
    );
  }
}
