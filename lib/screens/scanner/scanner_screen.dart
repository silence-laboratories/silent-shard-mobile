// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:async/async.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/backup_wallet/remind_enter_password_modal.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/copy_button.dart';
import 'package:silentshard/screens/components/padded_container.dart';
import 'package:silentshard/screens/error/multi_wallet_mismatch_screen.dart';
import 'package:silentshard/screens/error/wallet_mismatch_screen.dart';
import 'package:silentshard/screens/error/no_backup_found_while_repairing_screen.dart';
import 'package:silentshard/screens/error/wrong_metamask_wallet_for_recovery_screen.dart';
import 'package:silentshard/screens/error/wrong_password_recovery_screen.dart';
import 'package:silentshard/screens/error/wrong_timezone_screen.dart';
import 'package:silentshard/screens/scanner/guide_me_tabs.dart';
import 'package:silentshard/screens/wallet/wallet_screen.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/backup_wallet/backup_wallet_screen.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/loader.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/error/something_went_wrong_screen.dart';
import 'package:silentshard/screens/error/wrong_qr_code_screen.dart';
import "package:silentshard/extensions/string_extension.dart";
import 'package:silentshard/types/support_wallet.dart';
import '../../auth_state.dart';
import '../../services/backup_service.dart';
import '../../types/app_backup.dart';
import '../../repository/app_repository.dart';

class ScannerScreen extends StatefulWidget {
  final AppBackup? backup;
  final BackupSource? source;
  final bool? isRePairing;
  final String repairWalletId;
  final String repairAddress;

  const ScannerScreen({super.key, this.backup, this.source, this.isRePairing, this.repairWalletId = 'metamask', this.repairAddress = ''});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

enum ScannerState { scanning, scanned, error }

enum ScannerScreenPairingState { ready, inProgress, succeeded, failed }

class _ScannerScreenState extends State<ScannerScreen> {
  ScannerState _scannerState = ScannerState.scanning;
  ScannerScreenPairingState _pairingState = ScannerScreenPairingState.ready;
  CancelableOperation<dynamic>? _pairingOperation;
  MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  late AnalyticManager analyticManager;
  bool showRemindEnterPassword = false;
  bool isRecovery = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isRecovery = widget.isRePairing == true || widget.backup != null;
    });
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _updateScannerState(ScannerState newState) {
    setState(() {
      _scannerState = newState;
    });
  }

  void _updatePairingState(ScannerScreenPairingState newState) {
    if (mounted) {
      setState(() {
        _pairingState = newState;
      });
    }
  }

  void _resetScannerController() {
    setState(() {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    });
  }

  void _handleDetect(AppRepository sdk, AuthState authState, BarcodeCapture capture) {
    if (_scannerState != ScannerState.scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    final message = _parse(barcode?.rawValue);
    if (message != null) {
      FirebaseCrashlytics.instance.log('QR code scanned, pairingId: ${message.pairingId}');
      analyticManager.trackPairingDevice(
          type: widget.isRePairing ?? false
              ? PairingDeviceType.repaired
              : widget.backup?.walletBackup != null
                  ? PairingDeviceType.recovered
                  : PairingDeviceType.new_account,
          status: PairingDeviceStatus.qr_scanned);
      _updateScannerState(ScannerState.scanned);
      _startPairing(context, sdk, authState, message, widget.isRePairing ?? false);
    } else {
      _updateScannerState(ScannerState.scanned);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrongQRCodeScreen(onTap: () {
            _resetPairing();
          }),
        ),
      );
    }
  }

  Future<void> _finish(bool showBackupScreen, bool isRePair, AppRepository appRepository, String walletId) async {
    FirebaseCrashlytics.instance.log('Pairing finished, show save backup: $showBackupScreen');
    _updatePairingState(ScannerScreenPairingState.succeeded);

    await Future.delayed(const Duration(seconds: 2), () {});
    if (!mounted) return;

    if (showBackupScreen) {
      await appRepository.keygen(walletId);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BackupWalletScreen(walletId: walletId),
        ),
      );
    } else {
      if (widget.backup != null && widget.source == BackupSource.fileSystem) {
        final backupService = Provider.of<BackupService>(context, listen: false);
        backupService.backupToFileDidSave(widget.backup!); // update backup status
      }
      if (!isRePair && widget.backup != null && widget.source == BackupSource.secureStorage) {
        final backupService = Provider.of<BackupService>(context, listen: false);
        backupService.backupToStorageDidSave(widget.backup!);
      }
      if (walletId == 'metamask') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WalletScreen(
              pairedWalletId: walletId,
            ),
          ),
        );
      }
    }
  }

  Future<void> _startPairing(BuildContext context, AppRepository appRepository, AuthState authState, QRMessage qrMessage, bool isRePair) async {
    final userId = authState.user?.uid;
    if (userId == null) throw StateError('Attempt to pair when anauthenticated');
    if (_pairingState != ScannerScreenPairingState.ready) return;
    _updatePairingState(ScannerScreenPairingState.inProgress);

    if (isRePair) {
      _pairingOperation = appRepository.repair(qrMessage, userId);
    } else {
      _pairingOperation = appRepository.pair(qrMessage, userId, widget.backup?.walletBackup);
    }

    final hasBackupAlready = widget.backup != null;
    final showBackupScreen = !hasBackupAlready && !isRePair;
    final isScanningWithSameWallet = qrMessage.walletId == widget.repairWalletId;
    FirebaseCrashlytics.instance.log('Start pairing, isRepair: $isRePair, hasBackupAlready: $hasBackupAlready');
    if (isRecovery && isScanningWithSameWallet && widget.repairWalletId != 'metamask') {
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        showRemindEnterPassword = true;
      });
    }

    _pairingOperation?.value.then((pairingResponse) {
      analyticManager.trackPairingDevice(
        type: isRePair
            ? PairingDeviceType.repaired
            : hasBackupAlready
                ? PairingDeviceType.recovered
                : PairingDeviceType.new_account,
        status: PairingDeviceStatus.success,
      );
      FirebaseCrashlytics.instance.log('Pairing done');
      if (pairingResponse is PairingData && pairingResponse.remark == 'WALLET_MISMATCH') {
        FirebaseCrashlytics.instance.log('Wallet mismatch');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WalletMismatchScreen(
              onContinue: () {
                FirebaseCrashlytics.instance.log('Continue with new account');
                _finish(showBackupScreen, isRePair, appRepository, qrMessage.walletId);
              },
              onBack: () {
                FirebaseCrashlytics.instance.log('Cancel pairing');
                _pairingOperation?.cancel();
                _updatePairingState(ScannerScreenPairingState.ready);
                _resetPairing();
              },
            ),
          ),
        );
      } else if (isRecovery && !isScanningWithSameWallet) {
        SupportWallet oldWallet = SupportWallet.fromJson(walletMetaData[widget.repairWalletId]!);
        SupportWallet newWallet = SupportWallet.fromJson(walletMetaData[qrMessage.walletId]!);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiWalletMismatchScreen(
              oldWalletId: widget.repairWalletId,
              oldWalletIcon: oldWallet.icon,
              newWalletId: qrMessage.walletId,
              newWalletIcon: newWallet.icon,
              onContinue: () {
                _pairingOperation?.cancel();
                _updatePairingState(ScannerScreenPairingState.ready);
                _resetPairing();
              },
            ),
          ),
        );
      } else {
        _finish(showBackupScreen, isRePair, appRepository, qrMessage.walletId);
      }
    }, onError: (error) {
      FirebaseCrashlytics.instance.log('Pairing failed: $error');
      analyticManager.trackPairingDevice(
          type: isRePair
              ? PairingDeviceType.repaired
              : hasBackupAlready
                  ? PairingDeviceType.recovered
                  : PairingDeviceType.new_account,
          status: PairingDeviceStatus.failed,
          error: error.toString());
      _cancelPairing(true, error, qrMessage.walletId);
    });
  }

  void _resetPairing() {
    _updateScannerState(ScannerState.scanning);
    _resetScannerController();
  }

  void _cancelPairing(bool showTryAgain, [dynamic error, String walletId = 'metamask']) {
    _pairingOperation?.cancel();
    _updatePairingState(ScannerScreenPairingState.ready);
    if (error is StateError && error.toString().contains('NO_BACKUP_DATA_WHILE_REPAIRING')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoBackupFoundWhileRepairingScreen(onPress: () {
            _resetPairing();
          }),
        ),
      );
    } else if (error is StateError && error.toString().contains('INVALID_BACKUP_DATA')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => walletId == 'metamask'
              ? WrongMetaMaskWalletForRecoveryScreen(onPress: () {
                  _resetPairing();
                })
              : WrongPasswordRecoveryScreen(onPress: () {
                  _resetPairing();
                }),
        ),
      );
    } else if (error is StateError && error.toString().contains('RESOURCE_EXHAUSTED')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrongTimezoneScreen(
            onPress: () {
              _resetPairing();
              AppSettings.openAppSettings(type: AppSettingsType.date);
            },
            onBack: () {
              _resetPairing();
            },
          ),
        ),
      );
    } else if (showTryAgain) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SomethingWentWrongScreen(onPress: () {
            _resetPairing();
          }),
        ),
      );
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  QRMessage? _parse(String? scannedValue) {
    if (scannedValue == null) return null;

    try {
      final json = jsonDecode(scannedValue);
      final message = QRMessage.fromJson(json);
      return message;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    SupportWallet walletInfo = SupportWallet.fromJson(walletMetaData[widget.repairWalletId] ?? {});

    return Consumer<AppRepository>(
      builder: (context, appRepository, _) => Consumer<AuthState>(
        builder: (context, authState, _) => Stack(children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _cancelPairing(false);
                },
              ),
              backgroundColor: Colors.black,
              elevation: 0,
            ),
            body: Stack(children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(defaultSpacing * 1.5),
                  margin: const EdgeInsets.only(top: defaultSpacing * 0.5),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      isRecovery ? "Scan the QR code" : "Pair with desktop",
                      style: textTheme.displayLarge,
                    ),
                    const Gap(defaultSpacing),
                    if (isRecovery) ...<Bullet>[
                      Bullet(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Head to ', style: textTheme.displaySmall),
                              TextSpan(
                                  text: '${widget.repairWalletId.capitalize()} wallet',
                                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' on your browser/desktop.', style: textTheme.displaySmall),
                            ],
                          ),
                        ),
                      ),
                      Bullet(
                        child: Text("If the account is already present: select ‘recover account on phone’ from wallet menu option.",
                            style: textTheme.displaySmall),
                      ),
                      const Bullet(child: Text("Scan QR code with SL Logo and connect this device."))
                    ] else
                      Text(
                        "Point your camera at the QR code generated on your wallet on desktop to pair.",
                        style: textTheme.displaySmall,
                      ),
                    const Gap(defaultSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor2, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5, horizontal: defaultSpacing * 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            barrierColor: Colors.white.withOpacity(0.15),
                            showDragHandle: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            backgroundColor: sheetBackgroundColor,
                            context: context,
                            builder: (context) {
                              return GuideMeTabController(
                                isRePairing: widget.isRePairing,
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.import_contacts_outlined),
                        label: const Text(
                          'Guide me',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Gap(defaultSpacing * 2),
                    Stack(children: [
                      Container(
                        height: MediaQuery.of(context).size.width - 20,
                        padding: const EdgeInsets.all(10),
                        child: _scannerState == ScannerState.scanning
                            ? Builder(builder: (BuildContext context) {
                                return MobileScanner(
                                  controller: scannerController,
                                  onDetect: (object) => _handleDetect(appRepository, authState, object),
                                  errorBuilder: (p0, p1, p2) {
                                    SchedulerBinding.instance.addPostFrameCallback((_) {
                                      _updateScannerState(ScannerState.error);
                                    });
                                    return Container();
                                  },
                                );
                              })
                            : Container(
                                color: Colors.black,
                              ),
                      ),
                      if (_scannerState == ScannerState.scanning)
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 10)),
                          height: MediaQuery.of(context).size.width - 20,
                          padding: const EdgeInsets.all(20),
                          child: Image.asset('assets/images/scanArea.png'),
                        )
                    ]),
                    const Gap(defaultSpacing * 3),
                    GestureDetector(
                      onTap: () {
                        scannerController.toggleTorch();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                            valueListenable: scannerController.torchState,
                            builder: (BuildContext context, value, Widget? child) {
                              return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(
                                  value == TorchState.on ? Icons.flash_on : Icons.flash_off,
                                  color: primaryColor2,
                                ),
                                const Gap(defaultSpacing),
                                Text((value == TorchState.on) ? "Flash on" : 'Flash off',
                                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500))
                              ]);
                            }),
                      ),
                    )
                  ]),
                ),
              ),
              if (_scannerState == ScannerState.error)
                AlertDialog(
                  insetPadding: const EdgeInsets.all(defaultSpacing * 1.5),
                  content: Wrap(children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(defaultSpacing * 1.5),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Image.asset(
                          'assets/images/cameraDisabled.png',
                          width: 100,
                        ),
                        const Gap(defaultSpacing * 4),
                        Text(
                          'Allow Silent Shard to access your camera',
                          style: textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(defaultSpacing * 2),
                        Text(
                          "This let's you scan the QR code and pair your phone with your browser to create your Silent Account.",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const Gap(defaultSpacing * 4),
                        Button(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: Text(
                            'Open settings',
                            style: textTheme.bodyMedium,
                          ),
                        )
                      ]),
                    ),
                  ]),
                )
            ]),
          ),
          if (_scannerState == ScannerState.scanned)
            AlertDialog(
              content: !isRecovery
                  ? Stack(children: [
                      AnimatedOpacity(
                        opacity: (_pairingState == ScannerScreenPairingState.succeeded) ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: const Wrap(children: [
                          Check(text: 'Successfully paired!'),
                        ]),
                      ),
                      AnimatedOpacity(
                        opacity: !(_pairingState == ScannerScreenPairingState.succeeded) ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: const Wrap(children: [
                          Loader(text: 'Pairing with snap...'),
                        ]),
                      ),
                    ])
                  : Stack(children: [
                      showRemindEnterPassword == true
                          ? AnimatedOpacity(
                              opacity: showRemindEnterPassword == true ? 1 : 0,
                              duration: const Duration(milliseconds: 500),
                              child: !(_pairingState == ScannerScreenPairingState.succeeded)
                                  ? RemindEnterPasswordModal(isScanning: true, walletName: widget.repairWalletId.capitalize())
                                  : Column(mainAxisSize: MainAxisSize.min, children: [
                                      const Check(text: 'Account already present on App'),
                                      const Gap(defaultSpacing * 2),
                                      Container(
                                        margin: const EdgeInsets.only(bottom: defaultSpacing * 3),
                                        padding: const EdgeInsets.all(defaultSpacing * 1.5),
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: backgroundSecondaryColor2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
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
                                                    widget.repairAddress.isNotEmpty
                                                        ? '${widget.repairAddress.substring(0, 5)}...${widget.repairAddress.substring(widget.repairAddress.length - 5)}'
                                                        : '',
                                                    style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  const Gap(defaultSpacing),
                                                  CopyButton(onCopy: () async {
                                                    await Clipboard.setData(ClipboardData(text: widget.repairAddress));
                                                  }),
                                                  const SizedBox(width: 24),
                                                ]),
                                                Text(
                                                  walletInfo.name,
                                                  style: textTheme.displaySmall?.copyWith(fontSize: 12),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Button(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => WalletScreen(
                                                pairedWalletId: widget.repairWalletId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text('Continue', style: Theme.of(context).textTheme.displaySmall),
                                      ),
                                    ]),
                            )
                          : AnimatedOpacity(
                              opacity: showRemindEnterPassword == false ? 1 : 0,
                              duration: const Duration(milliseconds: 500),
                              child: Wrap(children: [Loader(text: 'Recovering with ${widget.repairWalletId.capitalize()}...')]),
                            ),
                    ]),
              insetPadding: const EdgeInsets.all(defaultSpacing * 1.5),
            ),
        ]),
      ),
    );
  }
}
