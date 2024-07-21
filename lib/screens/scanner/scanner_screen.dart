// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:async/async.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/error/keygen_last_round_error_screen.dart';
import 'package:silentshard/screens/error/multi_wallet_mismatch_screen.dart';
import 'package:silentshard/screens/error/no_backup_found_while_repairing_screen.dart';
import 'package:silentshard/screens/error/wrong_metamask_wallet_for_recovery_screen.dart';
import 'package:silentshard/screens/error/wrong_password_recovery_screen.dart';
import 'package:silentshard/screens/error/wrong_timezone_screen.dart';
import 'package:silentshard/screens/scanner/guide_me_tabs.dart';
import 'package:silentshard/screens/scanner/scanner_pair_status_dialog.dart';
import 'package:silentshard/screens/scanner/scanner_recovery_status_dialog.dart';
import 'package:silentshard/services/wallet_metadata_loader.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/backup_wallet/backup_wallet_screen.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/error/something_went_wrong_screen.dart';
import 'package:silentshard/screens/error/wrong_qr_code_screen.dart';
import 'package:silentshard/types/support_wallet.dart';
import 'package:silentshard/types/wallet_highlight_provider.dart';
import 'package:silentshard/utils.dart';
import '../../auth_state.dart';
import '../../services/backup_service.dart';
import '../../types/app_backup.dart';
import '../../repository/app_repository.dart';

class ScannerScreen extends StatefulWidget {
  final AppBackup? backup;
  final BackupSource? source;
  final bool isRePairing;
  final String recoveryWalletId;
  final String repairAddress;

  const ScannerScreen({super.key, this.backup, this.source, this.isRePairing = false, this.recoveryWalletId = '', this.repairAddress = ''});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

enum ScannerState { scanning, scanned, error }

enum ScannerScreenPairingState { ready, inProgress, succeeded, failed }

class _ScannerScreenState extends State<ScannerScreen> {
  ScannerState _scannerState = ScannerState.scanning;
  ScannerScreenPairingState _pairingState = ScannerScreenPairingState.ready;
  CancelableOperation<PairingData?> _pairingOperation = CancelableOperation<PairingData?>.fromFuture(Future.value(null));
  MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  late AnalyticManager analyticManager;
  late WalletMetadataLoader walletMetadataLoader;
  bool showRemindEnterPassword = false;
  bool showAccountAlreadyPresent = false;
  bool isRecovery = false; // for cases: repair, recover with backup
  String recoveryAddress = '';
  String scanningWalletId = '';
  SupportWallet? walletInfo;

  @override
  void initState() {
    super.initState();
    walletMetadataLoader = Provider.of<WalletMetadataLoader>(context, listen: false);

    setState(() {
      isRecovery = widget.backup != null || widget.isRePairing;
      walletInfo = walletMetadataLoader.getWalletMetadata(widget.recoveryWalletId);
    });

    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _updateScannerState(ScannerState newState) {
    if (mounted) {
      setState(() {
        _scannerState = newState;
      });
    }
  }

  void _updatePairingState(ScannerScreenPairingState newState) {
    if (mounted) {
      setState(() {
        _pairingState = newState;
      });
    }
  }

  void _updateRecoveryState(bool isAccountPresent, String address) {
    if (mounted) {
      setState(() {
        showAccountAlreadyPresent = isAccountPresent;
        recoveryAddress = address;
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
    FirebaseCrashlytics.instance.log('QR code scanned, pairingId: ${message?.pairingId}');
    analyticManager.trackPairingDevice(
        address: "",
        wallet: message?.walletId ?? WALLET_ID_NOT_FOUND,
        type: widget.isRePairing
            ? PairingDeviceType.repaired
            : widget.backup?.walletBackup != null
                ? PairingDeviceType.recovered
                : PairingDeviceType.new_account,
        status: PairingDeviceStatus.qr_scanned);
    _updateScannerState(ScannerState.scanned);
    if (message != null) {
      _startPairing(context, sdk, authState, message);
    } else {
      FirebaseCrashlytics.instance.log('QR code scanned, no message found');
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

  Future<void> _finishPairing(AppRepository appRepository, String walletId, String userId, PairingData? pairingData) async {
    FirebaseCrashlytics.instance.log('Pairing finished, ${isRecovery ? 'show save backup screen' : 'starting keygen'}');

    if (!isRecovery) {
      try {
        final result = await appRepository.keygen(walletId, userId, pairingData);
        _updatePairingState(ScannerScreenPairingState.succeeded);
        await Future.delayed(const Duration(seconds: 2), () {});
        final address = result.ethAddress;
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BackupWalletScreen(walletId: walletId, address: address),
            ),
          );
        }
      } catch (e) {
        FirebaseCrashlytics.instance.log('Keygen failed: $e');
        _updatePairingState(ScannerScreenPairingState.failed);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KeygenLastRoundErrorScreen(
                onContinue: () {
                  _resetPairing();
                },
              ),
            ),
          );
        }
      }
    } else {
      if (!widget.isRePairing && widget.backup != null) {
        if (widget.source == BackupSource.fileSystem) {
          final backupService = Provider.of<BackupService>(context, listen: false);
          backupService.backupToFileDidSave(widget.backup!); // update backup status
        }
        if (widget.source == BackupSource.secureStorage) {
          final backupService = Provider.of<BackupService>(context, listen: false);
          backupService.backupToStorageDidSave(widget.backup!);
        }
      }

      _updatePairingState(ScannerScreenPairingState.succeeded);
      await Future.delayed(const Duration(seconds: 2), () {});
      if (!showAccountAlreadyPresent) {
        _toWalletScreenAfterRecovery();
      }
    }
  }

  Future<void> _startPairing(BuildContext context, AppRepository appRepository, AuthState authState, QRMessage qrMessage) async {
    final userId = authState.user?.uid;
    if (userId == null) throw StateError('Attempt to pair when unauthenticated');
    if (_pairingState != ScannerScreenPairingState.ready) return;

    _updatePairingState(ScannerScreenPairingState.inProgress);
    setState(() {
      scanningWalletId = qrMessage.walletId;
    });

    final hasBackupAlready = widget.backup != null;
    if (hasBackupAlready) {
      final keyshareList = appRepository.keysharesProvider.keyshares[qrMessage.walletId];
      final backupAddress = widget.backup?.walletBackup.accounts.firstOrNull?.address ?? '';
      bool isBackupSameAccount = keyshareList?.any((element) => element.ethAddress == backupAddress) ?? false;
      _updateRecoveryState(isBackupSameAccount, backupAddress);
    } else if (widget.isRePairing == true) {
      bool isRePairingSameAccount = widget.recoveryWalletId == qrMessage.walletId;
      _updateRecoveryState(isRePairingSameAccount, widget.repairAddress);
    }
    if ((hasBackupAlready || widget.isRePairing) && widget.recoveryWalletId != qrMessage.walletId) {
      analyticManager.trackPairingDevice(
        address: widget.isRePairing || hasBackupAlready ? recoveryAddress : "",
        wallet: qrMessage.walletId,
        type: widget.isRePairing
            ? PairingDeviceType.repaired
            : hasBackupAlready
                ? PairingDeviceType.recovered
                : PairingDeviceType.new_account,
        status: PairingDeviceStatus.failed,
        error: WALLET_MISMATCH,
      );
      SupportWallet oldWallet = walletMetadataLoader.getWalletMetadata(widget.recoveryWalletId);
      SupportWallet newWallet = walletMetadataLoader.getWalletMetadata(qrMessage.walletId);
      if (context.mounted) {
        _updatePairingState(ScannerScreenPairingState.failed);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiWalletMismatchScreen(
              address: recoveryAddress,
              oldWalletId: widget.recoveryWalletId,
              oldWalletIcon: oldWallet.icon,
              newWalletId: qrMessage.walletId,
              newWalletIcon: newWallet.icon,
              onContinue: () {
                _resetPairing();
              },
            ),
          ),
        );
      }
      return;
    }

    if (widget.isRePairing == true) {
      _pairingOperation = appRepository.repair(qrMessage, widget.repairAddress, userId);
    } else {
      _pairingOperation = appRepository.pair(qrMessage, userId, widget.backup?.walletBackup);
    }

    if (isRecovery && qrMessage.walletId != METAMASK_WALLET_ID) {
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        showRemindEnterPassword = true;
      });
    }

    FirebaseCrashlytics.instance.log('Start pairing, isRepair: ${widget.isRePairing}, hasBackupAlready: $hasBackupAlready');
    _pairingOperation.value.then((pairingResponse) {
      analyticManager.trackPairingDevice(
        address: widget.isRePairing || hasBackupAlready ? recoveryAddress : "",
        wallet: qrMessage.walletId,
        type: widget.isRePairing
            ? PairingDeviceType.repaired
            : hasBackupAlready
                ? PairingDeviceType.recovered
                : PairingDeviceType.new_account,
        status: PairingDeviceStatus.success,
      );
      FirebaseCrashlytics.instance.log('Pairing done');
      _finishPairing(appRepository, qrMessage.walletId, userId, pairingResponse);
    }, onError: (error) {
      FirebaseCrashlytics.instance.log('Pairing failed: $error');
      analyticManager.trackPairingDevice(
          address: widget.isRePairing || hasBackupAlready ? recoveryAddress : "",
          wallet: qrMessage.walletId,
          type: widget.isRePairing
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
    _pairingOperation.cancel();
    _updatePairingState(ScannerScreenPairingState.ready);
    _updateScannerState(ScannerState.scanning);
    _resetScannerController();
  }

  void _cancelPairing(bool showTryAgain, [dynamic error, String walletId = METAMASK_WALLET_ID]) {
    _pairingOperation.cancel();
    if (error is StateError && error.toString().contains('NO_BACKUP_DATA_WHILE_REPAIRING')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoBackupFoundWhileRepairingScreen(onPress: () {
            _resetPairing();
          }),
        ),
      );
    } else if (error is StateError && error.toString().contains('INVALID_BACKUP_DATA') && walletId == METAMASK_WALLET_ID) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => WrongMetaMaskWalletForRecoveryScreen(onPress: () {
                  _resetPairing();
                })),
      );
    } else if (error is StateError && error.toString().contains('WRONG_PASSWORD')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrongPasswordRecoveryScreen(onPress: () {
            _resetPairing();
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);
          }),
        ),
      );
    } else if (error is StateError && error.toString().contains('RESOURCE_EXHAUSTED')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrongTimezoneScreen(
            onGotoSettings: () {
              Navigator.of(context).pop();
              _resetPairing();
              AppSettings.openAppSettings(type: AppSettingsType.date);
            },
            onTryAgain: () {
              _resetPairing();
              Navigator.of(context).pop();
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
        _resetPairing();
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

  void _toWalletScreenAfterRecovery() async {
    context.read<WalletHighlightProvider>().setPairedAddress(recoveryAddress);
    context.read<WalletHighlightProvider>().setScrolledTemporarily();
    _resetPairing();
    Navigator.of(context).pop();
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
                              TextSpan(text: '${walletInfo?.name} wallet', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
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
                  ? ScannerPairStatusDialog(
                      isNotSucceed: !(_pairingState == ScannerScreenPairingState.succeeded),
                      walletName: scanningWalletId.capitalize(),
                    )
                  : ScannerRecoveryStatusDialog(
                      isSucceedWithNewAccount: _pairingState == ScannerScreenPairingState.succeeded && !showAccountAlreadyPresent,
                      isSucceedWithPresentAccount: _pairingState == ScannerScreenPairingState.succeeded && showAccountAlreadyPresent,
                      isRecoverWithBackup: widget.backup != null,
                      showRemindEnterPassword: showRemindEnterPassword,
                      isInProgress: _pairingState == ScannerScreenPairingState.inProgress,
                      walletInfo: walletInfo,
                      recoveryAddress: recoveryAddress,
                      toWalletScreenAfterRecovery: _toWalletScreenAfterRecovery,
                    ),
              insetPadding: const EdgeInsets.all(defaultSpacing * 1.5),
            ),
        ]),
      ),
    );
  }
}
