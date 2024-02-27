// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/error/no_backup_found_while_repairing_screen.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/backup_wallet_screen.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/loader.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/error/something_went_wrong_screen.dart';
import 'package:silentshard/screens/error/wrong_qr_code_screen.dart';
import '../auth_state.dart';
import '../services/backup_service.dart';
import '../types/app_backup.dart';
import '../repository/app_repository.dart';

class ScannerScreen extends StatefulWidget {
  final AppBackup? backup;
  final BackupSource? source;
  final bool? isRePairing;

  const ScannerScreen({super.key, this.backup, this.source, this.isRePairing});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

enum ScannerState { scanning, scanned, error }

enum ScannerScreenPairingState { ready, inProgress, succeeded, failed }

class _ScannerScreenState extends State<ScannerScreen> {
  ScannerState _scannerState = ScannerState.scanning;
  MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  late AnalyticManager analyticManager;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  ScannerScreenPairingState _pairingState = ScannerScreenPairingState.ready;

  CancelableOperation<void>? _pairingOperation;

  void _updateScannerState(ScannerState newState) {
    setState(() {
      _scannerState = newState;
    });
  }

  void _updatePairingState(ScannerScreenPairingState newState) {
    setState(() {
      _pairingState = newState;
    });
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

  @override
  void initState() {
    super.initState();
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
  }

  void _handleDetect(AppRepository sdk, AuthState authState, BarcodeCapture capture) {
    if (_scannerState != ScannerState.scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    final message = _parse(barcode?.rawValue);
    if (message != null) {
      analyticManager.trackPairingDevice(
          type: widget.isRePairing ?? false
              ? PairingDeviceType.repaired
              : widget.backup?.walletBackup != null
                  ? PairingDeviceType.recovered
                  : PairingDeviceType.start,
          status: PairingDeviceStatus.qr_scanned);
      _updateScannerState(ScannerState.scanned);
      _startPairing(context, sdk, authState, message, widget.isRePairing ?? false);
    } else {
      _updateScannerState(ScannerState.scanned);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrongQRCodeScreen(onTap: () {
            _updateScannerState(ScannerState.scanning);
            _resetScannerController();
          }),
        ),
      );
    }
  }

  Future<void> _finish(bool saveBackup, bool isRePair) async {
    _updatePairingState(ScannerScreenPairingState.succeeded);

    await Future.delayed(const Duration(seconds: 2), () {});
    if (!mounted) return;

    if (saveBackup) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BackupWalletScreen(),
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
      Navigator.of(context).pop();
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
    final shouldSaveBackup = !hasBackupAlready && !isRePair;
    _pairingOperation?.value.then((_) {
      analyticManager.trackPairingDevice(
        type: isRePair
            ? PairingDeviceType.repaired
            : hasBackupAlready
                ? PairingDeviceType.recovered
                : PairingDeviceType.start,
        status: PairingDeviceStatus.success,
      );

      _finish(shouldSaveBackup, isRePair);
    }, onError: (error) {
      analyticManager.trackPairingDevice(
          type: isRePair
              ? PairingDeviceType.repaired
              : hasBackupAlready
                  ? PairingDeviceType.recovered
                  : PairingDeviceType.start,
          status: PairingDeviceStatus.failed,
          error: error.toString());
      _cancelPairing(true, error);
    });
  }

  void _cancelPairing(bool showTryAgain, [dynamic error]) {
    _pairingOperation?.cancel();
    _updatePairingState(ScannerScreenPairingState.ready);
    if (error.toString().contains('NO_BACKUP_DATA_WHILE_REPAIRING')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoBackupFoundWhileRepairingScreen(onPress: () {
            _updateScannerState(ScannerState.scanning);
            _resetScannerController();
          }),
        ),
      );
    } else if (showTryAgain) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SomethingWentWrongScreen(onPress: () {
            _updateScannerState(ScannerState.scanning);
            _resetScannerController();
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
                  padding: const EdgeInsets.all(defaultPadding * 1.5),
                  margin: const EdgeInsets.only(top: defaultPadding * 0.5),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      "Scan the QR code",
                      style: textTheme.displayLarge,
                    ),
                    const Gap(defaultPadding),
                    Bullet(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Open ', style: textTheme.displaySmall),
                            TextSpan(text: 'snap.silencelaboratories.com', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' in your desktop.', style: textTheme.displaySmall),
                          ],
                        ),
                      ),
                    ),
                    Bullet(
                      child: Text("Connect Silent Shard Snap with your MetaMask extension.", style: textTheme.displaySmall),
                    ),
                    if (widget.isRePairing == true)
                      Bullet(
                        child: RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              TextSpan(text: 'If account is already present:  press on the', style: textTheme.displaySmall),
                              const WidgetSpan(
                                child: Icon(
                                  Icons.more_vert,
                                  size: 20,
                                ),
                              ),
                              TextSpan(
                                  text: 'icon and click on ‘Recover account on phone’ and follow the instructions', style: textTheme.displaySmall),
                            ],
                          ),
                        ),
                      ),
                    Bullet(
                      child: RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text: 'Scan QR code with ', style: textTheme.displaySmall),
                            WidgetSpan(
                              child: Image.asset('assets/icon/silentShardLogo.png', height: 20, width: 20),
                            ),
                            TextSpan(text: ' Silent Shard', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' logo and connect this device.', style: textTheme.displaySmall),
                          ],
                        ),
                      ),
                    ),
                    const Gap(defaultPadding * 2),
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
                    const Gap(defaultPadding * 3),
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
                                const Gap(defaultPadding),
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
                  backgroundColor: secondaryColor,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
                  content: Wrap(children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(defaultPadding * 1.5),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Image.asset(
                          'assets/images/cameraDisabled.png',
                          width: 100,
                        ),
                        const Gap(defaultPadding * 4),
                        Text(
                          'Allow Silent Shard to access your camera',
                          style: textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(defaultPadding * 2),
                        Text(
                          "This let's you scan the QR code and pair your phone with your browser to create your Silent Account.",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const Gap(defaultPadding * 4),
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
              backgroundColor: secondaryColor,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              content: Stack(children: [
                AnimatedOpacity(
                  opacity: (_pairingState == ScannerScreenPairingState.succeeded) ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: const Wrap(children: [
                    Check(text: 'Paired successfully!'),
                  ]),
                ),
                AnimatedOpacity(
                  opacity: !(_pairingState == ScannerScreenPairingState.succeeded) ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: const Wrap(children: [
                    Loader(text: 'Pairing with snap...'),
                  ]),
                ),
              ]),
              insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
            ),
        ]),
      ),
    );
  }
}
