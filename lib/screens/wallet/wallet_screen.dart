// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:silentshard/demo/state_decorators/backups_provider.dart';
import 'package:silentshard/screens/error/corrupted_backup_error_screen.dart';
import 'package:silentshard/screens/pairing/pair_screen.dart';
import 'package:silentshard/screens/wallet/wallet_list.dart';
import 'package:silentshard/auth_state.dart';
import 'package:silentshard/screens/update/updater_dialog.dart';
import 'package:silentshard/services/backup_service.dart';
import 'package:silentshard/services/chain_loader.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/demo/state_decorators/keyshares_provider.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/screens/settings_screen.dart';
import 'package:silentshard/screens/sign/approve_transcation_screen.dart';
import 'package:silentshard/screens/wallet/notification_alert.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import '../sign/sign_request_view_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

enum AllowNotificationAlertState { showing, notShowing }

class _WalletScreenState extends State<WalletScreen> with WidgetsBindingObserver {
  StreamSubscription<SignRequest>? _signRequestsSubscription;
  StreamSubscription<BackupMessage>? _backupMessageSubscription;

  AllowNotificationAlertState _notificationAlertState = AllowNotificationAlertState.notShowing;
  AuthorizationStatus _notificationStatus = AuthorizationStatus.notDetermined;
  late AnalyticManager analyticManager;
  _updateNotificationAlertState(AllowNotificationAlertState value) {
    setState(() {
      _notificationAlertState = value;
    });
  }

  _updateNotificationStatus(AuthorizationStatus value) {
    setState(() {
      _notificationStatus = value;
    });
  }

  // FirebaseMessaging does not return correct Notification status, return denied for notDetermined case in Android.
  // We are using Permission library to handle this particular case.
  Future<AuthorizationStatus> _getNotificatioSettingsStatus() async {
    final isPermanentlyDenied = await Permission.notification.isPermanentlyDenied;
    if (isPermanentlyDenied) return AuthorizationStatus.denied;
    final firebaseNotificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
    if (firebaseNotificationSettings.authorizationStatus == AuthorizationStatus.authorized ||
        firebaseNotificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      return AuthorizationStatus.authorized;
    }
    if (Platform.isIOS) return firebaseNotificationSettings.authorizationStatus;
    return AuthorizationStatus.notDetermined;
  }

  Future<void> setupInteractedPushMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handlePushMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushMessage);
  }

  void _handlePushMessage(RemoteMessage message) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.user?.uid;
    analyticManager.trackNotificationClick(userId: userId ?? "", notificationTitle: message.notification?.title ?? "");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupInteractedPushMessage();
    final appRepository = Provider.of<AppRepository>(context, listen: false);
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);

    final authState = Provider.of<AuthState>(context, listen: false);

    final userId = authState.user?.uid;
    if (userId != null) {
      FirebaseCrashlytics.instance.log('Listening to sign requests');
      _signRequestsSubscription = appRepository.signRequests(userId).listen(_handleSignRequest, onError: (error) {
        analyticManager.trackSignInitiated(from: "", wallet: "", error: error.toString());
      });
      _backupMessageSubscription = appRepository.listenRemoteBackupMessage(userId: userId).listen((event) {});
    }

    _getNotificatioSettingsStatus().then((value) {
      _updateNotificationStatus(value);
      FirebaseCrashlytics.instance.log('Notification permission status: $value');
      if (value == AuthorizationStatus.notDetermined) {
        _updateNotificationAlertState(AllowNotificationAlertState.showing);
      }
    });
  }

  @override
  void deactivate() {
    _signRequestsSubscription?.cancel();
    _backupMessageSubscription?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _getNotificatioSettingsStatus().then((value) {
          _updateNotificationStatus(value);
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Consumer<BackupsProvider>(builder: (context, backupsProvider, _) {
        for (MapEntry<String, WalletBackup> entry in backupsProvider.walletBackupsMap.entries) {
          final walletId = entry.key;
          for (AccountBackup accountBackup in entry.value.accounts) {
            if (accountBackup.remoteData.length == NULL_ENCRYPTED_LENGTH) {
              final address = accountBackup.address;
              FirebaseCrashlytics.instance.log('Backup of ${entry.key} wallet with ${accountBackup.address} is broken.');
              analyticManager.trackCorruptBackupDetected(walletId: walletId, address: address);
              return CorruptedBackupErrorScreen(
                onContinue: () async {
                  final backupService = Provider.of<BackupService>(context, listen: false);
                  final appRepository = Provider.of<AppRepository>(context, listen: false);
                  appRepository.deleteBackup(walletId, address);
                  await backupService.removeBackupFromStorage(walletId, address);
                },
              );
            }
          }
        }
        return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(children: [
              Container(
                padding: const EdgeInsets.all(defaultSpacing * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(defaultSpacing * 4),
                    WalletScreenHeader(textTheme: textTheme),
                    const Gap(defaultSpacing * 3),
                    if (_notificationStatus == AuthorizationStatus.denied || _notificationStatus == AuthorizationStatus.notDetermined) ...[
                      GestureDetector(
                        onTap: () async {
                          await _getNotificatioSettingsStatus().then(
                            (value) async {
                              if (value == AuthorizationStatus.denied) {
                                AppSettings.openAppSettings(type: AppSettingsType.notification);
                              } else {
                                await FirebaseMessaging.instance.requestPermission().then((permissions) {
                                  _updateNotificationStatus(permissions.authorizationStatus);
                                });
                              }
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(defaultSpacing),
                          decoration: BoxDecoration(border: Border.all(color: warningColor), borderRadius: BorderRadius.circular(defaultSpacing)),
                          child: const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Icon(
                              Icons.error,
                              color: warningColor,
                              size: 16,
                            ),
                            Gap(defaultSpacing),
                            Text(
                              'Enable notification',
                              style: TextStyle(fontSize: 12, color: warningColor),
                            )
                          ]),
                        ),
                      ),
                      const Gap(defaultSpacing * 2)
                    ],
                    const Expanded(child: WalletList()),
                  ],
                ),
              ),
              Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
                bool isMetaMaskWallet = keysharesProvider.keyshares.containsKey(METAMASK_WALLET_ID);
                return UpdaterDialog(
                  showSnapUpdate: isMetaMaskWallet,
                );
              }),
              if (_notificationAlertState == AllowNotificationAlertState.showing)
                Consumer<LocalAuth>(builder: (context, localAuth, _) {
                  return AllowNotificationAlert(
                      localAuth: localAuth,
                      updateNotificationStatus: _updateNotificationStatus,
                      updateNotificationAlertState: _updateNotificationAlertState);
                }),
            ]),
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
              backgroundColor: Colors.transparent,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PairScreen(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/FAB.png',
                height: 64,
                width: 64,
              ),
            ));
      }),
    );
  }

  Future<void> _handleSignRequest(SignRequest requst) async {
    FirebaseCrashlytics.instance.log('New sign request, chainId: ${requst.chainId}');
    final chainLoader = Provider.of<ChainLoader>(context, listen: false);
    _signRequestsSubscription?.pause();
    Future<Chain> chain = chainLoader.getChainInfo(requst.chainId);

    final requestModel = SignRequestViewModel(requst, chain);
    analyticManager.trackSignInitiated(from: requst.from, wallet: requst.walletId ?? WALLET_ID_NOT_FOUND, signType: requestModel.signType);
    _showConfirmationDialog(requst.walletId ?? "", requestModel, requst.from);
  }

  void _showConfirmationDialog(String walletId, SignRequestViewModel requestModel, String address) {
    showModalBottomSheet(
      barrierColor: Colors.white.withOpacity(0.15),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: sheetBackgroundColor,
      context: context,
      builder: (context) => ApproveTransactionScreen(
        address: address,
        walletId: walletId,
        requestModel: requestModel,
        resumeSignRequestSubscription: () {
          _signRequestsSubscription?.resume();
        },
      ),
    );
  }
}

class WalletScreenHeader extends StatelessWidget {
  const WalletScreenHeader({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        "Silent Shard",
        style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {
          FirebaseCrashlytics.instance.log('Open settings screen');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.settings_outlined, color: textPrimaryColor),
      )
    ]);
  }
}

class AllowNotificationAlert extends StatelessWidget {
  const AllowNotificationAlert(
      {super.key, required this.localAuth, required this.updateNotificationStatus, required this.updateNotificationAlertState});
  final LocalAuth localAuth;
  final Function(AuthorizationStatus value) updateNotificationStatus;
  final Function(AllowNotificationAlertState value) updateNotificationAlertState;
  @override
  Widget build(BuildContext context) {
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    return NotificationAlertDialog(
      onDeny: () {
        analyticManager.trackAllowPermissions(notifications: AllowPermissionsNoti.denied, source: PageSource.homepage, error: "User denied request");
        updateNotificationStatus(AuthorizationStatus.notDetermined);
        updateNotificationAlertState(AllowNotificationAlertState.notShowing);
      },
      onAllow: () async {
        await FirebaseMessaging.instance.requestPermission().then((permissions) {
          updateNotificationStatus(permissions.authorizationStatus);
          FirebaseCrashlytics.instance.log('Notification permission status allow: $permissions');
          if (permissions.authorizationStatus == AuthorizationStatus.authorized ||
              permissions.authorizationStatus == AuthorizationStatus.provisional) {
            analyticManager.trackAllowPermissions(notifications: AllowPermissionsNoti.allowed, source: PageSource.homepage);
          } else if (permissions.authorizationStatus == AuthorizationStatus.denied) {
            analyticManager.trackAllowPermissions(
                notifications: AllowPermissionsNoti.denied, source: PageSource.homepage, error: "User denied request");
          } else {
            analyticManager.trackAllowPermissions(
                notifications: AllowPermissionsNoti.denied, source: PageSource.homepage, error: "Permission status unknowns");
          }
        });
        if (Provider.of<AppPreferences>(context, listen: false).getIsLocalAuthRequired() == false) {
          bool res = await localAuth.authenticate();
          FirebaseCrashlytics.instance.log('Local auth setup: $res');
          if (res) {
            Provider.of<AppPreferences>(context, listen: false).setIsLocalAuthRequired(true);
          }
          bool isLocalAuthSupported = await localAuth.canAuthenticate();
          if (isLocalAuthSupported) {
            analyticManager.trackAllowPermissions(
                deviceLock: res ? AllowPermissionsDeviceLock.allowed : AllowPermissionsDeviceLock.denied,
                source: PageSource.homepage,
                error: res ? null : "User denied request");
          } else {
            analyticManager.trackAllowPermissions(
                notifications: AllowPermissionsNoti.allowed, deviceLock: AllowPermissionsDeviceLock.na, source: PageSource.homepage);
          }
        }
        updateNotificationAlertState(AllowNotificationAlertState.notShowing);
      },
    );
  }
}
