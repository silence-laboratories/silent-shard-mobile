// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../third_party/analytics.dart';
import '../repository/app_repository.dart';
import 'backup_service.dart';
import '../types/file_name.dart';
import '../utils.dart';

abstract interface class UseCase<R> {
  Future<R> execute(String walletId, String address);
}

class SaveBackupToStorageUseCase extends UseCase {
  final BuildContext context;

  SaveBackupToStorageUseCase(this.context);

  @override
  Future<void> execute(String walletId, String address) async {
    if (!context.mounted) {
      return Future.error(StateError('Cannot export backup: context is not mounted'));
    }

    final appRepository = Provider.of<AppRepository>(context, listen: false);
    final backupService = Provider.of<BackupService>(context, listen: false);

    return appRepository
        .appBackup(walletId, address)
        .value //
        .then((appBackup) => backupService.saveBackupToStorage(walletId, appBackup));
  }
}

class ExportBackupUseCase extends UseCase {
  final BuildContext context;
  ExportBackupUseCase(this.context);

  @override
  Future<void> execute(String walletId, String address) async {
    if (!context.mounted) {
      return Future.error(StateError('Cannot export backup: context is not mounted'));
    }

    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    try {
      final appRepository = Provider.of<AppRepository>(context, listen: false);
      final backupService = Provider.of<BackupService>(context, listen: false);
      final appBackup = await appRepository.appBackup(walletId, address).value;

      if (appBackup.walletBackup.accounts.isEmpty) {
        return Future.error(StateError('Cannot export backup: empty wallet'));
      }

      final tempFile = await backupService.saveBackupToFile(walletId, appBackup);
      final isIPad = await PlatformUtils.isPad;
      if (context.mounted) {
        final obj = context.findRenderObject();
        if (obj == null) {
          Future.error(StateError('Render box not found'));
        }

        bool isBox = obj is RenderBox;
        if (isBox == false) {
          Future.error(StateError('Render box not found'));
        }

        final box = obj as RenderBox;
        final result = await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: tempFile.filename,
          sharePositionOrigin: isIPad ? box.localToGlobal(Offset.zero) & box.size : null,
        );
        if (result.status != ShareResultStatus.dismissed) {
          analyticManager.trackSaveToFile(wallet: walletId, address: address, success: true, source: PageSource.backup_page, backup: result.raw);
          backupService.backupToFileDidSave(appBackup);
        } else {
          analyticManager.trackSaveToFile(
              wallet: walletId,
              address: address,
              success: false,
              source: PageSource.backup_page,
              backup: result.raw,
              error: "Save to file is dismissed.");
        }
      }
    } catch (e) {
      analyticManager.trackSaveToFile(wallet: walletId, address: address, success: false, source: PageSource.backup_page, error: e.toString());
      return Future.error(e);
    }
  }
}
