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
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/screens/local_auth_screen.dart';
import 'package:silentshard/screens/login_screen_wrapper.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import 'package:silentshard/services/secure_storage/secure_storage_service.dart';
import 'package:silentshard/theme/theme_constants.dart';
import 'package:silentshard/theme/theme_manager.dart';

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
  final appRepository = AppRepository(sdk);
  final appPreferences = AppPreferences(sharedPreferences);
  final firebaseMessaging = MessagingService(authState, appRepository);
  firebaseMessaging.start();

  final signInService = SignInService();
  final secureStorage = SecureStorage();
  await secureStorage.init();

  final fileService = FileService();
  final backupService = BackupService(fileService, secureStorage, appPreferences);
  final themeManager = ThemeManager();
  final mixpanelManager = AnalyticManager(appRepository.keysharesProvider);

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
        Provider(create: (_) => mixpanelManager),
        ChangeNotifierProvider(create: (_) => backupService), // ignore: unnecessary_cast
        ChangeNotifierProvider(create: (_) => appPreferences),
        ChangeNotifierProvider(create: (_) => appRepository.pairingDataProvider),
        ChangeNotifierProvider(create: (_) => appRepository.keysharesProvider),
        ChangeNotifierProvider(create: (_) => authState),
        ChangeNotifierProvider(create: (_) => themeManager),
        ChangeNotifierProvider(create: (_) => localAuth),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        // themeMode: themeManager.themeMode, TODO
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      body: Consumer<LocalAuth>(
        builder: (context, localAuth, _) => Consumer<AuthState>(
          builder: (context, authState, _) => Consumer<PairingDataProvider>(
            builder: (context, pairingDataProvider, _) => Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
              bool isLocalAuthRequired = Provider.of<AppPreferences>(context, listen: false).getIsLocalAuthRequired();
              return switch ((
                (!localAuth.isAuthenticated) && isLocalAuthRequired,
                authState.user,
                pairingDataProvider.pairingData,
                keysharesProvider.keyshares.firstOrNull
              )) {
                (false, _?, _?, _?) => const SignScreen(),
                (false, _?, _, _) => const PairScreen(),
                (false, null, _, _) => const LoginScreenWrapper(),
                (true, _, _, _) => LocalAuthScreen(localAuth: localAuth),
              };
            }),
          ),
        ),
      ),
    );
  }
}
