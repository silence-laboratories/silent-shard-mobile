// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:silentshard/services/chain_loader.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/demo/state_decorators/keyshares_provider.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/screens/backup/backup_destination_screen.dart';
import 'package:silentshard/screens/settings_screen.dart';
import 'package:silentshard/screens/sign/approve_transcation_screen.dart';
import 'package:silentshard/screens/scanner_screen.dart';
import 'package:silentshard/screens/sign/confirm_unpair.dart';
import 'package:silentshard/screens/sign/notification_alert.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import '../sign/sign_request_view_model.dart';
import 'wallet_card.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

enum SignScreenNotificationAlertState { showing, notShowing }

class _SignScreenState extends State<SignScreen> with WidgetsBindingObserver {
  StreamSubscription<SignRequest>? _signRequestsSubscription;
  SignScreenNotificationAlertState _notificationAlertState = SignScreenNotificationAlertState.notShowing;
  AuthorizationStatus _notificationStatus = AuthorizationStatus.notDetermined;
  late AnalyticManager analyticManager;
  _updateNotificationAlertState(SignScreenNotificationAlertState value) {
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final appRepository = Provider.of<AppRepository>(context, listen: false);

    FirebaseCrashlytics.instance.log('Listening to sign requests');
    _signRequestsSubscription = appRepository.signRequests().listen(_handleSignRequest);

    _getNotificatioSettingsStatus().then((value) {
      _updateNotificationStatus(value);
      FirebaseCrashlytics.instance.log('Notification permission status: ${value}');
      if (value == AuthorizationStatus.notDetermined) {
        _updateNotificationAlertState(SignScreenNotificationAlertState.showing);
      }
    });
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    final keyshareProvider = Provider.of<KeysharesProvider>(context, listen: false);
    analyticManager.setUserProfileProps(prop: "public_key", value: keyshareProvider.keyshares.firstOrNull?.ethAddress ?? "");
  }

  @override
  void deactivate() {
    _signRequestsSubscription?.cancel();
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
      child: Stack(children: [
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(defaultPadding * 4),
                Row(children: [
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
                ]),
                const Gap(defaultPadding * 3),
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
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(border: Border.all(color: warningColor), borderRadius: BorderRadius.circular(defaultPadding)),
                      child: const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Icon(
                          Icons.error,
                          color: warningColor,
                          size: 16,
                        ),
                        Gap(defaultPadding),
                        Text(
                          'Enable notification',
                          style: TextStyle(fontSize: 12, color: warningColor),
                        )
                      ]),
                    ),
                  ),
                  const Gap(defaultPadding * 2)
                ],
                Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
                  var address = keysharesProvider.keyshares.firstOrNull?.ethAddress;
                  return address != null
                      ? WalletCard(
                          onRepair: _repair,
                          onExport: () => _exportBackup(address),
                          onLogout: () => _confirmSignOut(address),
                          address: address,
                          onCopy: () async {
                            await Clipboard.setData(ClipboardData(text: address));
                          })
                      : Container();
                }),
                const Gap(defaultPadding * 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Image.asset('assets/images/signTransaction.png'),
                ),
                const Gap(defaultPadding * 5),
                Text(
                  "No pending transactions. Initiate any transaction from MetaMask extension to approve it here.",
                  style: textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (_notificationAlertState == SignScreenNotificationAlertState.showing)
          Consumer<LocalAuth>(builder: (context, localAuth, _) {
            return NotificationAlertDialog(
              onDeny: () {
                analyticManager.trackAllowPermissions(
                    notifications: AllowPermissionsNoti.denied, source: PageSource.homepage, error: "User denied request");
                _updateNotificationStatus(AuthorizationStatus.notDetermined);
                _updateNotificationAlertState(SignScreenNotificationAlertState.notShowing);
              },
              onAllow: () async {
                await FirebaseMessaging.instance.requestPermission().then((permissions) {
                  _updateNotificationStatus(permissions.authorizationStatus);
                  FirebaseCrashlytics.instance.log('Notification permission status allow: ${permissions}');
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
                _updateNotificationAlertState(SignScreenNotificationAlertState.notShowing);
              },
            );
          }),
      ]),
    );
  }

  void _repair() async {
    FirebaseCrashlytics.instance.log('Initiated repair');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(isRePairing: true),
      ),
    );
  }

  void _confirmSignOut(String address) {
    FirebaseCrashlytics.instance.log('Initiated sign out');
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: sheetBackgroundColor,
        barrierColor: Colors.white.withOpacity(0.15),
        showDragHandle: true,
        context: context,
        builder: (context) => ConfirmUnpair(address: address, onUnpair: _signOut));
  }

  void _exportBackup(String address) async {
    FirebaseCrashlytics.instance.log('Open export backup');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupDestinationScreen(address: address),
      ),
    );
  }

  Future<void> _signOut() async {
    FirebaseCrashlytics.instance.log('Signing out');
    Provider.of<AppRepository>(context, listen: false).reset();
  }

  Future<void> _handleSignRequest(SignRequest requst) async {
    FirebaseCrashlytics.instance.log('New sign request, chainId: ${requst.chainId}');
    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    final chainLoader = Provider.of<ChainLoader>(context, listen: false);
    _signRequestsSubscription?.pause();
    Future<Chain> chain = chainLoader.getChainInfo(requst.chainId);

    final requestModel = SignRequestViewModel(requst, chain);
    analyticManager.trackSignInitiated();
    _showConfirmationDialog(requestModel);
  }

  void _showConfirmationDialog(SignRequestViewModel requestModel) {
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
        requestModel: requestModel,
        resumeSignRequestSubscription: () {
          _signRequestsSubscription?.resume();
        },
      ),
    );
  }
}
