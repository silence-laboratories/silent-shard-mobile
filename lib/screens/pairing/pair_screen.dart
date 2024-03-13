// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:credential_manager/credential_manager.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/auth_state.dart';
import 'package:silentshard/services/sign_in_service.dart';
import 'package:silentshard/third_party/analytics.dart';

import '../../constants.dart';
import '../components/loader.dart';
import '../components/padded_container.dart';
import '../error/error_handler.dart';
import '../error/no_backup_found_screen.dart';
import '../scanner_screen.dart';
import '../../types/app_backup.dart';
import '../../services/backup_service.dart';
import '../../services/secure_storage/secure_storage_service.dart';
import 'backup_picker.dart';
import 'backup_source_picker.dart';

class PairScreen extends StatefulWidget {
  const PairScreen({super.key});

  @override
  State<PairScreen> createState() => _PairState();
}

enum PairingState { ready, fetchingBackup }

class _PairState extends State<PairScreen> {
  PairingState _pairingState = PairingState.ready;
  late AnalyticManager analyticManager;

  Future<void> checkAuth() async {
    try {
      FirebaseCrashlytics.instance.log("Initiated anonymous login");
      SignInService signInService = Provider.of<SignInService>(context, listen: false);
      final userAuth = await signInService.signInAnonymous();
      analyticManager.trackSignIn(userId: userAuth.user?.uid ?? '', status: SignInStatus.success);
      FirebaseCrashlytics.instance.setUserIdentifier(userAuth.user?.uid ?? '');
    } catch (e) {
      FirebaseCrashlytics.instance.log('Sign in failed $e');
      analyticManager.trackSignIn(userId: '', status: SignInStatus.failed, error: e.toString());
      if (e.toString().contains('firebase_auth/network-request-failed')) {
        // ignore: use_build_context_synchronously
        _showNoInternetError(context);
      } else {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorHandler(
              onPressBottomButton: () {
                Navigator.pop(context);
                checkAuth();
              },
            ),
          ),
        );
      }
    }
  }

  void _showNoInternetError(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorHandler(
          errorTitle: 'No internet connection',
          errorSubtitle: Text(
            'Please connect to internet and try again',
            style: textTheme.bodyMedium,
          ),
          onPressBottomButton: () {
            Navigator.pop(context);
            checkAuth();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
    checkAuth();
  }

  void _handleBackupFetch(BackupSource source, [String? key]) async {
    try {
      FirebaseCrashlytics.instance.log('Fetching backup, soure: $source');
      setState(() => _pairingState = PairingState.fetchingBackup);
      final backupService = Provider.of<BackupService>(context, listen: false);
      final backup = await backupService.fetchBackup(source, key);
      if (backup != null) {
        FirebaseCrashlytics.instance.log('Backup fetched');
        _recoverFromBackup(backup, source);
      } else {
        FirebaseCrashlytics.instance.log('No backup found');
        _showNoBackupFound(source);
      }
    } catch (error) {
      _showError(error, source);
      print('Error recovering from credentionals: $error');
      FirebaseCrashlytics.instance.log('Error recovering from credentionals: $error');
    } finally {
      setState(() => _pairingState = PairingState.ready);
    }
  }

  void _showError(Object error, BackupSource source) {
    if (error is CredentialException && error.code == 201) {
      // User cancelled, ignore
    } else if (error is CredentialException && error.code == 202) {
      _showNoBackupFound(source);
    } else {
      _showErrorScreen(source);
    }
  }

  void _showErrorScreen(BackupSource source) {
    final textTheme = Theme.of(context).textTheme;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorHandler(
          errorSubtitle: Text(
            textAlign: TextAlign.center,
            'The backup up file might be wrong or else corrupted.',
            style: textTheme.bodyMedium,
          ),
          onPressBottomButton: () {
            _handleBackupSource(source);
          },
        ),
      ),
    );
  }

  void _showNoBackupFound(BackupSource source) {
    if (source == BackupSource.fileSystem) {
      return; // user has cancelled file picker
    }

    if (source == BackupSource.secureStorage) {
      analyticManager.trackRecoverBackupSystem(success: false, source: PageSource.get_started, error: "No backup found.");
    } else {
      analyticManager.trackRecoverFromFile(success: false, source: PageSource.get_started, error: "No backup found.");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoBackupFoundScreen(onPressBottomButton: () {
          Navigator.pop(context);
          _handleBackupFetch(source);
        }),
      ),
    );
  }

  void _recoverFromBackup(AppBackup backup, BackupSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(backup: backup, source: source),
      ),
    );
  }

  void _goToScannerScreen() {
    FirebaseCrashlytics.instance.log('Create new account');
    analyticManager.trackConnectNewAccount();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    );
  }

  void _showBackupSourcePicker() {
    _showModalBottomSheet(
      (context) => BackupSourcePicker(onSelected: _handleBackupSource),
    );
  }

  void _handleBackupSource(BackupSource source) {
    Navigator.of(context).pop();
    if (source == BackupSource.secureStorage && Platform.isIOS) {
      _showBackupPicker();
    } else {
      _handleBackupFetch(source);
    }
  }

  void _showBackupPicker() async {
    final secureStorage = Provider.of<SecureStorageService>(context, listen: false);
    final list = await secureStorage.readAll();
    if (!mounted) return;

    showModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 0.75,
      backgroundColor: Colors.black,
      barrierColor: Colors.white.withOpacity(0.15),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => BackupPicker(
        list: list,
        onSelected: (key) {
          Navigator.of(context).pop();
          _handleBackupFetch(BackupSource.secureStorage, key);
        },
      ),
    );
  }

  void _showModalBottomSheet(WidgetBuilder builder) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.white.withOpacity(0.15),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: Consumer<AuthState>(builder: (context, authState, _) {
            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: authState.user == null,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(defaultPadding * 1.5),
                      margin: const EdgeInsets.only(top: defaultPadding * 0.5),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          "Let's get started",
                          style: textTheme.displayLarge,
                        ),
                        const Gap(defaultPadding * 3),
                        PairOption(
                          type: OptionType.primary,
                          icon: const Icon(Icons.add, color: Colors.white),
                          title: 'Connect your account',
                          subtitle: 'Scan QR and Connect your browser to create new account.',
                          infoText: "For new users",
                          onPress: _goToScannerScreen,
                        ),
                        const Gap(defaultPadding * 3),
                        PairOption(
                          type: OptionType.secondary,
                          icon: const Icon(Icons.replay, color: Colors.white),
                          title: 'Restore existing account',
                          subtitle: 'Choose backup file to recover your existing wallet.',
                          infoText: "For existing users",
                          onPress: _showBackupSourcePicker,
                        ),
                        Gap(defaultPadding * 6),
                        GestureDetector(
                          child: Text(
                            'Crash',
                            style: textTheme.bodyMedium,
                          ),
                          onTap: () {
                            FirebaseCrashlytics.instance.crash();
                          },
                        )
                      ]),
                    ),
                  ),
                ),
                if (_pairingState == PairingState.fetchingBackup) ...[
                  const AlertDialog(
                    backgroundColor: secondaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Wrap(children: [Loader(text: 'Fetching backup...')]),
                  )
                ],
                if (authState.user == null)
                  const AlertDialog(
                    backgroundColor: secondaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Wrap(children: [Loader(text: 'Getting ready...')]),
                  )
              ],
            );
          })),
    );
  }
}

enum OptionType { primary, secondary }

class PairOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onPress;
  final OptionType type;
  final String infoText;
  const PairOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPress,
    required this.type,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.only(
          left: defaultPadding * 1.5,
          top: defaultPadding * 2,
          bottom: defaultPadding * 2,
          right: defaultPadding * 1.5,
        ),
        backgroundColor: type == OptionType.primary ? backgroundPrimaryColor.withOpacity(0.30) : const Color(0xFF1A1A1A),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaddedContainer(
            color: type == OptionType.primary ? backgroundPrimaryColor2 : backgroundSecondaryColor2,
            child: icon,
          ),
          const Gap(defaultPadding * 1.5),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500)),
              const Gap(defaultPadding * 1.5),
              Text(subtitle, style: textTheme.displaySmall),
              const Gap(defaultPadding * 1.5),
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                    border: Border.all(color: type == OptionType.primary ? backgroundPrimaryColor2 : backgroundSecondaryColor3, width: 1),
                    borderRadius: BorderRadius.circular(50)),
                child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: textPrimaryColor,
                  ),
                  const Gap(defaultPadding),
                  Text(
                    infoText,
                    style: const TextStyle(fontSize: 12, color: textPrimaryColor),
                  )
                ]),
              )
            ]),
          )
        ],
      ),
    );
  }
}
