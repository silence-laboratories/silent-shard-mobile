// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/services/backup_service.dart';
import 'package:silentshard/types/backup_info.dart';

import '../../constants.dart';
import '../components/button.dart';
import '../components/backup_status_dashboard.dart';

class ConfirmUnpair extends StatefulWidget {
  final String address;
  final String walletId;
  final Future<void> Function() onUnpair;

  const ConfirmUnpair({
    super.key,
    required this.address,
    required this.onUnpair,
    required this.walletId,
  });

  @override
  State<ConfirmUnpair> createState() => _ConfirmUnpairState();
}

enum CheckBoxState { checked, unchecked }

class _ConfirmUnpairState extends State<ConfirmUnpair> {
  CheckBoxState _checkboxState = CheckBoxState.unchecked;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
          // color: secondaryColor,
          padding: const EdgeInsets.all(defaultSpacing * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure?",
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(defaultSpacing * 2),
              Center(
                  child: Image.asset(
                'assets/images/warningRed.png',
                height: 130,
              )),
              const Gap(defaultSpacing * 2),
              Text(
                "This action will delete your Silent Account from your phone. You can still restore it with your backup files.",
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(defaultSpacing * 2),
              const Divider(),
              const Gap(defaultSpacing * 2),
              BackupStatusDashboard(address: widget.address, walletId: widget.walletId),
              const Gap(defaultSpacing * 6),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: _checkboxState == CheckBoxState.checked ? true : false,
                      onChanged: (value) {
                        setState(() {
                          _checkboxState = (value ?? false) ? CheckBoxState.checked : CheckBoxState.unchecked;
                        });
                      },
                    ),
                  ),
                  const Gap(defaultSpacing),
                  Flexible(
                    child: Text(
                      'I understand the risk and agree to continue',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const Gap(defaultSpacing * 2),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      type: ButtonType.secondary,
                      activeColor: const Color(0xFF25194D),
                      onPressed: () {
                        analyticManager.trackDeleteAccount(status: DeleteAccountStatus.cancelled);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: textTheme.displaySmall?.copyWith(color: primaryColor2),
                      ),
                    ),
                  ),
                  const Gap(defaultSpacing * 2),
                  Expanded(
                    child: Button(
                      type: ButtonType.primary,
                      isDisabled: _checkboxState != CheckBoxState.checked,
                      buttonColor: const Color(0xFFF87171).withOpacity(_checkboxState == CheckBoxState.checked ? 1 : 0.5),
                      activeColor: const Color(0xFFDB4E4E),
                      onPressed: () async {
                        if (_checkboxState == CheckBoxState.checked) {
                          final backupService = context.read<BackupService>();
                          final backupSystemStatus = getBackupCheck(backupService.getBackupInfo(widget.address), BackupSource.secureStorage).status;
                          final backupFileStatus = getBackupCheck(backupService.getBackupInfo(widget.address), BackupSource.fileSystem).status;
                          analyticManager.trackDeleteAccount(
                            status: DeleteAccountStatus.success,
                            backupFile: backupFileStatus == BackupStatus.done,
                            backupSystem: backupSystemStatus == BackupStatus.done,
                          );
                          await widget.onUnpair();
                          analyticManager.trackLogOut();
                          if (mounted) Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Delete',
                        style: textTheme.displaySmall,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(defaultSpacing * 4),
            ],
          )),
    );
  }
}
