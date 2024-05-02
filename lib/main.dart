// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentshard/services/chain_loader.dart';
import 'package:silentshard/screens/onboarding_screen.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/screens/local_auth_screen.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import 'package:silentshard/services/secure_storage/secure_storage_service.dart';
import 'package:silentshard/theme/theme_constants.dart';
import 'package:silentshard/theme/theme_manager.dart';
import 'package:silentshard/types/wallet_highlight_provider.dart';

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
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final sdk = Dart2PartySDK(FirebaseTransport());
  await sdk.init();

  final authState = AuthState();
  final localAuth = LocalAuth();
  final analyticManager = AnalyticManager();
  await analyticManager.init();
  final appRepository = AppRepository(sdk, analyticManager);
  analyticManager.keysharesProvider = appRepository.keysharesProvider;
  final appPreferences = AppPreferences(sharedPreferences);
  final firebaseMessaging = MessagingService(authState, appRepository);
  firebaseMessaging.start();

  final signInService = SignInService();
  final secureStorage = SecureStorage();
  await secureStorage.init().catchError((e) {
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  });
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
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
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
        ChangeNotifierProvider(create: (_) => backupService), // ignore: unnecessary_cast
        ChangeNotifierProvider(create: (_) => appPreferences),
        ChangeNotifierProvider(create: (_) => appRepository.pairingDataProvider),
        ChangeNotifierProvider(create: (_) => appRepository.keysharesProvider),
        ChangeNotifierProvider(create: (_) => authState),
        ChangeNotifierProvider(create: (_) => themeManager),
        ChangeNotifierProvider(create: (_) => localAuth),
        ChangeNotifierProvider(create: (_) => walletIdProvider)
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

class _MyAppState extends State<MyApp> {
  final secureStorage = SecureStorage();
  bool showOnboardingScreen = true;
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
                final ethAddress = keysharesProvider.keyshares["metamask"]?.firstOrNull?.ethAddress ?? '';
                FirebaseCrashlytics.instance.setCustomKey("ethAddress", ethAddress);
                widget.analyticManager.setUserProfileProps(prop: "public_key", value: ethAddress);
                return switch ((
                  (!localAuth.isAuthenticated) && isLocalAuthRequired,
                  appPreferences.getIsOnboardingCompleted(),
                  pairingDataProvider.pairingData,
                  keysharesProvider.keyshares.isNotEmpty
                )) {
                  (false, true, _, true) => const WalletScreen(),
                  (false, true, _, false) => PairScreen(),
                  (false, false, _, _) => const OnboardingScreen(),
                  (true, _, _, _) => LocalAuthScreen(localAuth: localAuth),
                };
              }),
            ),
          ),
        ));
  }
}
