import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';

import '../../constants.dart';
import '../../services/backup_service.dart';
import '../../services/backup_use_cases.dart';
import '../../types/backup_info.dart';
import '../../utils.dart';
import '../components/Button.dart';
import '../components/PaddedContainer.dart';
import '../components/message_widget.dart';
import '../error/error_handler.dart';

class BackupDestinationScreen extends StatelessWidget {
  final String address;

  const BackupDestinationScreen({super.key, required this.address});

  String get _cloudIconName => Platform.isAndroid ? "socialGoogle.png" : "socialApple.png";
  Image get _cloudIcon => Image.asset("assets/images/$_cloudIconName", height: 20);

  String get _cloudTitle => Platform.isAndroid ? "Google Password Manager" : "iCloud Keychain";
  String get _storageTitle => Platform.isAndroid ? "Google" : "iCloud";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(2 * defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Backup wallet",
                  style: textTheme.displayLarge,
                ),
                const Gap(defaultPadding),
                Text(
                  "Secure your wallet by backing up using $_cloudTitle or by exporting to files.",
                  style: textTheme.displaySmall,
                ),
                const Gap(9 * defaultPadding),
                Consumer<BackupService>(
                    builder: (context, backupService, _) => BackupDestinationWidget(
                          address: address,
                          icon: _cloudIcon,
                          title: "Backup to $_cloudTitle",
                          label: "Recommended",
                          // check: BackupCheck(BackupStatus.done),
                          check: backupService.getBackupInfo(address).cloud,
                          destination: BackupDestination.secureStorage,
                        )),
                const Gap(4 * defaultPadding),
                const Divider(),
                const Gap(4 * defaultPadding),
                Consumer<BackupService>(
                    builder: (context, backupService, _) => BackupDestinationWidget(
                          address: address,
                          icon: Image.asset("assets/images/file-tray-full_light.png", height: 20),
                          title: "Export wallet",
                          subtitle: "Export and save a copy of your wallet backup to your Files or $_storageTitle Drive",
                          // check: BackupCheck(BackupStatus.pending),
                          check: backupService.getBackupInfo(address).file,
                          destination: BackupDestination.fileSystem,
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackupDestinationWidget extends StatelessWidget {
  final String address;
  final Image icon;
  final String title;
  final String? subtitle;
  final String? label;
  final BackupCheck check;
  final BackupDestination destination;

  const BackupDestinationWidget({
    super.key,
    required this.address,
    required this.icon,
    required this.title,
    required this.check,
    required this.destination,
    this.subtitle,
    this.label,
  });

  void _performBackup(BuildContext context, BackupDestination destination) async {
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    try {
      final useCase = switch (destination) {
        BackupDestination.fileSystem => ExportBackupUseCase(context),
        BackupDestination.secureStorage => SaveBackupToStorageUseCase(context),
      };
      await useCase.execute();

      if (destination == BackupDestination.secureStorage) {
        analyticManager.trackSaveBackupSystem(success: true, source: PageSource.backup_page);
      } else {
        analyticManager.trackSaveToFile(success: true, source: PageSource.backup_page);
      }
    } catch (error) {
      print('Cannot backup: $error');

      if (destination == BackupDestination.secureStorage) {
        analyticManager.trackSaveBackupSystem(success: false, source: PageSource.backup_page, error: error.toString());
      } else {
        analyticManager.trackSaveToFile(success: false, source: PageSource.backup_page, error: error.toString());
      }

      if (error is CredentialException && error.code == 301) {
        return; // Save cancelled, ignore
      }
      if (context.mounted) {
        _showErrorScreen(
          context,
          destination: destination,
          retryAction: () => _performBackup(context, destination),
        );
      }
    }
  }

  void _verifyBackup(BuildContext context) async {
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    ;
    try {
      final backupService = Provider.of<BackupService>(context, listen: false);
      await backupService.verifyBackup(address);
      analyticManager.trackVerifyBackup(
        success: true,
        timeSinceVerify: cloudMessage(check.date),
        source: PageSource.get_started,
      );
    } catch (error) {
      print('Cannot verify backup: $error');
      analyticManager.trackVerifyBackup(
          success: false, timeSinceVerify: cloudMessage(check.date), source: PageSource.get_started, error: error.toString());
      if (context.mounted) {
        _showErrorScreen(
          context,
          destination: destination,
          retryAction: () => _verifyBackup(context),
        );
      }
    }
  }

  void _showErrorScreen(BuildContext context, {required BackupDestination destination, required VoidCallback retryAction}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorHandler(
          onPressBottomButton: () {
            Navigator.pop(context);
            retryAction();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _performBackup(context, destination),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Row(children: [
            PaddedContainer(
              padding: const EdgeInsets.all(1.5 * defaultPadding),
              child: icon,
            ),
            const Gap(defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, textAlign: TextAlign.left, style: textTheme.displaySmall),
                  if (subtitle != null) ...[
                    const Gap(defaultPadding),
                    Text(subtitle!, maxLines: 3, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (label != null) ...[
              const Gap(4 * defaultPadding),
              LabelWidget(label!),
            ],
          ]),
          Gap(defaultPadding * check.status.distanceFactor),
          StatusWidget(check: check, destination: destination),
          if (Platform.isAndroid && destination == BackupDestination.secureStorage && check.status == BackupStatus.done) ...[
            const Gap(defaultPadding),
            Row(children: [
              const Gap(6 * defaultPadding),
              Button(
                type: ButtonType.primary,
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0),
                buttonColor: primaryColor,
                onPressed: () => _verifyBackup(context),
                child: Text('Verify backup', style: textTheme.displaySmall),
              ),
            ])
          ],
        ]),
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  final BackupCheck check;
  final BackupDestination destination;

  const StatusWidget({super.key, required this.check, required this.destination});

  String get _details => switch (destination) {
        BackupDestination.fileSystem => fileMessage(check.date),
        BackupDestination.secureStorage => Platform.isAndroid ? cloudMessage(check.date) : "Backup valid",
      };

  @override
  Widget build(BuildContext context) {
    return switch (check.status) {
      BackupStatus.pending || BackupStatus.missing => MessageWidget(check.status.message, type: check.status.messageType),
      BackupStatus.done => Row(children: [
          const Gap(6 * defaultPadding),
          check.status.statusIcon,
          const Gap(defaultPadding),
          Expanded(child: Text(_details, style: Theme.of(context).textTheme.bodySmall)),
        ]),
    };
  }
}

class LabelWidget extends StatelessWidget {
  final String text;

  const LabelWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0.5 * defaultPadding),
      decoration: BoxDecoration(
        color: infoBackgroundColor,
        border: Border.all(color: infoColor),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(text, style: textTheme.labelSmall),
    );
  }
}

extension BackupStatusUtils on BackupStatus {
  static const iconHeight = 16.0;

  String get message => switch (this) {
        BackupStatus.pending => "Action pending",
        BackupStatus.done => "Backup valid",
        BackupStatus.missing => "Backup not found. Backup now!",
      };

  MessageType get messageType => switch (this) {
        BackupStatus.pending => MessageType.warning,
        BackupStatus.done => MessageType.info,
        BackupStatus.missing => MessageType.error,
      };

  Color get statusIconColor => switch (this) {
        BackupStatus.pending => warningColor,
        BackupStatus.done => doneIconColor,
        BackupStatus.missing => warningColor,
      };

  Image get statusIcon => Image.asset("assets/images/checkmark-circle_light.png", height: iconHeight, color: statusIconColor);

  double get distanceFactor => switch (this) {
        BackupStatus.pending || BackupStatus.missing => 3,
        BackupStatus.done => 1,
      };
}
