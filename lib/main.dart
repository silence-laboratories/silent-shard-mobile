// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentshard/screens/error/wrong_timezone_screen.dart';
import 'package:silentshard/services/app_updater_service.dart';
import 'package:silentshard/services/chain_loader.dart';
import 'package:silentshard/screens/onboarding_screen.dart';
import 'package:silentshard/services/firebase_remote_config_service.dart';
import 'package:silentshard/services/snap_service.dart';
import 'package:silentshard/services/wallet_metadata_loader.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/screens/local_auth_screen.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import 'package:silentshard/services/secure_storage/secure_storage_service.dart';
import 'package:silentshard/theme/theme_constants.dart';
import 'package:silentshard/theme/theme_manager.dart';
import 'package:silentshard/types/wallet_highlight_provider.dart';
import 'package:silentshard/utils.dart';

import 'demo/state_decorators/keyshares_provider.dart';
import 'demo/state_decorators/pairing_data_provider.dart';
import 'repository/app_repository.dart';
import 'services/secure_storage/secure_storage.dart';
import 'services/file_service.dart';
import 'services/backup_service.dart';
import 'firebase_options.dart';
import 'auth_state.dart';
import 'screens/wallet/wallet_screen.dart';
import 'services/messaging_service.dart';
import 'screens/pairing/pair_screen.dart' show PairScreen;
import 'services/sign_in_service.dart';
import 'transport/firebase_transport.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();
  final analyticManager = AnalyticManager();
  final secureStorage = SecureStorage();
  final walletMetadataLoader = WalletMetadataLoader();
  final Dart2PartySDK sdk = Dart2PartySDK(FirebaseTransport());

  late SharedPreferences sharedPreferences;
  late PackageInfo packageInfo;

  await Future.wait([
    SharedPreferences.getInstance().then((value) => sharedPreferences = value),
    PackageInfo.fromPlatform().then((value) => packageInfo = value),
    sdk.init(),
    analyticManager.init(),
    FirebaseRemoteConfigService().initialize(),
    secureStorage.init().catchError((e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }),
    walletMetadataLoader.loadWalletMetadata(),
    preloadImage(),
  ]);

  final authState = AuthState();
  final localAuth = LocalAuth();
  final appRepository = AppRepository(sdk, analyticManager);
  final appPreferences = AppPreferences(sharedPreferences);
  final firebaseMessaging = MessagingService(authState, appRepository);
  firebaseMessaging.start();
  final appUpdaterService = AppUpdaterService(Version(packageInfo.version));
  final snapService = SnapService(appRepository);

  final signInService = SignInService();
  final fileService = FileService();
  final backupService = BackupService(fileService, secureStorage, appPreferences, analyticManager);
  final themeManager = ThemeManager();
  final chainLoader = ChainLoader();
  final walletIdProvider = WalletHighlightProvider();

  // Initiate the anonymous sign in process
  FirebaseCrashlytics.instance.log("Initiate anonymous login");
  signInService.signInAnonymous();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => appRepository),
        Provider(create: (_) => signInService),
        Provider(create: (_) => secureStorage as SecureStorageService), // ignore: unnecessary_cast
        Provider(create: (_) => analyticManager),
        Provider(create: (_) => chainLoader),
        Provider(create: (_) => walletMetadataLoader),
        ChangeNotifierProvider(create: (_) => backupService), // ignore: unnecessary_cast
        ChangeNotifierProvider(create: (_) => appPreferences),
        ChangeNotifierProvider(create: (_) => appRepository.pairingDataProvider),
        ChangeNotifierProvider(create: (_) => appRepository.keysharesProvider),
        ChangeNotifierProvider(create: (_) => appRepository.backupsProvider),
        ChangeNotifierProvider(create: (_) => authState),
        ChangeNotifierProvider(create: (_) => themeManager),
        ChangeNotifierProvider(create: (_) => localAuth),
        ChangeNotifierProvider(create: (_) => walletIdProvider),
        ChangeNotifierProvider(create: (_) => snapService),
        ChangeNotifierProvider(create: (_) => appUpdaterService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        // themeMode: themeManager.themeMode, TODO
        home: MyApp(analyticManager: analyticManager),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({required this.analyticManager, super.key});
  final AnalyticManager analyticManager;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final secureStorage = SecureStorage();
  bool showOnboardingScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTimeConsistency();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTimeConsistency();
    }
  }

  Future<void> _checkTimeConsistency() async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getServerTimestamp');
      final results = await callable();

      final deviceTimestamp = DateTime.timestamp().millisecondsSinceEpoch;
      final serverTimestamp = results.data['timeStamp'];
      final difference = deviceTimestamp - serverTimestamp;
      if (difference.abs() > 5000) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WrongTimezoneScreen(onGotoSettings: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.date);
              }, onTryAgain: () {
                Navigator.of(context).pop();
              }),
            ),
          );
        }
      }
    } catch (e) {
      FirebaseCrashlytics.instance.log('Get server timestamp failed! $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<AppPreferences>(
          builder: (context, appPreferences, _) => Consumer<LocalAuth>(
            builder: (context, localAuth, _) => Consumer<PairingDataProvider>(
              builder: (context, pairingDataProvider, _) => Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
                bool isLocalAuthRequired = Provider.of<AppPreferences>(context, listen: false).getIsLocalAuthRequired();
                // TODO: Identify crashlytics and mixpanel user by wallet's public key
                final ethAddress = keysharesProvider.keyshares[METAMASK_WALLET_ID]?.firstOrNull?.ethAddress ?? '';
                widget.analyticManager.setUserProfileProps(prop: "public_key", value: ethAddress);

                return switch ((
                  (!localAuth.isAuthenticated) && isLocalAuthRequired,
                  appPreferences.getIsOnboardingCompleted(),
                  pairingDataProvider.pairingData,
                  keysharesProvider.keyshares.isNotEmpty
                )) {
                  (false, true, _, true) => const WalletScreen(),
                  (false, true, _, false) => const PairScreen(),
                  (false, false, _, _) => const OnboardingScreen(),
                  (true, _, _, _) => LocalAuthScreen(localAuth: localAuth),
                };
              }),
            ),
          ),
        ));
  }
}
