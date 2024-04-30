import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/services/app_updater_service.dart';
import 'package:silentshard/services/snap_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class Updater extends StatefulWidget {
  const Updater({super.key});

  @override
  State<Updater> createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> {
  bool showSnapUpdateGuide = false;
  bool showSnapUpdateSuccessful = false;

  _updateShowSnapUpdateGuide(bool value) {
    setState(() {
      showSnapUpdateGuide = value;
    });
  }

  _handleAppUpdate() {
    Uri emailLaunchUri = Uri.parse(
      Platform.isAndroid ? "market://details?id=com.silencelaboratories.silentshard" : "https://apps.apple.com/app/id6468993285",
    );
    launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Consumer<SnapService>(
      builder: (context, snapService, _) => Consumer<AppUpdaterService>(builder: (context, appUpdaterService, _) {
        if (appUpdaterService.forceUpdateApp != null) {
          return switch ((
            appUpdaterService.forceUpdateApp!,
            snapService.forceUpdateSnap ?? false,
            showSnapUpdateGuide,
            snapService.showSnapUpdateSuccessful
          )) {
            (false, true, false, false) => SnapUpdateAlert(
                textTheme: textTheme,
                onPressSnapGuide: () {
                  _updateShowSnapUpdateGuide(true);
                }),
            (_, true, true, false) => UpdateSnapGuide(
                textTheme: textTheme,
                onBack: () {
                  _updateShowSnapUpdateGuide(false);
                }),
            (_, _, _, true) => SnapUpdatedSuccesfully(
                textTheme: textTheme,
                onContinue: () {
                  snapService.showSnapUpdateSuccessful = false;
                }),
            (true, true, false, false) => SnapAndAppUpdateAlert(
                textTheme: textTheme,
                onAppUpdate: _handleAppUpdate,
                onPressSnapGuide: () {
                  _updateShowSnapUpdateGuide(true);
                },
              ),
            (true, false, _, _) => AppUpdateAlert(textTheme: textTheme, onAppUpdate: _handleAppUpdate),
            (false, false, _, false) => Container(),
          };
        } else {
          return Container();
        }
      }),
    );
  }
}

class AppUpdateAlert extends StatelessWidget {
  final VoidCallback onAppUpdate;
  const AppUpdateAlert({
    super.key,
    required this.textTheme,
    required this.onAppUpdate,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: Wrap(children: [
        Column(
          children: [
            Image.asset("assets/images/updateRocket.png", width: 150),
            const Gap(defaultPadding * 3),
            Text(
              'It’s time for a power-up ',
              style: textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 2.5),
            Text(
              'Your Silent Shard app needs an immediate update to keep everything running smoothly and securely. ',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 4),
            Button(
              onPressed: onAppUpdate,
              child: Text('Update now', style: textTheme.displayMedium),
            ),
          ],
        )
      ]),
    );
  }
}

class SnapAndAppUpdateAlert extends StatelessWidget {
  final VoidCallback onAppUpdate;
  final VoidCallback onPressSnapGuide;

  const SnapAndAppUpdateAlert({
    super.key,
    required this.textTheme,
    required this.onAppUpdate,
    required this.onPressSnapGuide,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: SingleChildScrollView(
          child: Column(
        children: [
          Image.asset("assets/images/updateRocket.png", width: 150),
          const Gap(defaultPadding * 3),
          Text(
            'Updates are pending! ',
            style: textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const Gap(defaultPadding * 2.5),
          Text(
            'Your Silent Shard app and your MetaMask SNAP need an immediate update to keep everything running smoothly and securely. ',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(defaultPadding * 4),
          Button(
            type: ButtonType.secondary,
            onPressed: onPressSnapGuide,
            child: Text('Guide for Snap update', style: textTheme.displayMedium),
          ),
          const Gap(defaultPadding * 2),
          Button(
            onPressed: onAppUpdate,
            child: Text('Update app now', style: textTheme.displayMedium),
          ),
        ],
      )),
    );
  }
}

class UpdateSnapGuide extends StatelessWidget {
  final VoidCallback onBack;
  const UpdateSnapGuide({
    super.key,
    required this.textTheme,
    required this.onBack,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: SingleChildScrollView(
          child: Column(
        children: [
          Stack(
            children: [
              Image.asset("assets/images/updateLaptop.png", width: 250),
            ],
          ),
          const Gap(defaultPadding * 3),
          Bullet(
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'On your desktop browser, visit ',
                    style: textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: 'snap.silencelaboratories.com',
                    style: textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Bullet(
              child: Text(
            'Connect your MetaMask wallet to the DApp',
            style: textTheme.bodyMedium,
          )),
          Bullet(
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Once in the DApp home page, you will have an option to ',
                    style: textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: '"Update your Snap"',
                    style: textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextSpan(
                    text: ' to the latest version.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Bullet(
              child: Text(
            'Click on the Update button and follow the instructions.',
            style: textTheme.bodyMedium,
          )),
          const Gap(defaultPadding * 4),
          Button(
              type: ButtonType.secondary,
              onPressed: onBack,
              child: Text(
                'Go back',
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
              ))
        ],
      )),
    );
  }
}

class SnapUpdateAlert extends StatelessWidget {
  final VoidCallback onPressSnapGuide;
  const SnapUpdateAlert({
    super.key,
    required this.textTheme,
    required this.onPressSnapGuide,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/updateRocket.png", width: 150),
            const Gap(defaultPadding * 3),
            Text(
              'Seems like you are using an outdated Snap version',
              style: textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding),
            Text(
              'Your Silent Shard App is shiny new and can’t really comprehend what the old version of MetaMask Snap is saying.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 2),
            Text(
              'Update your Snap now to keep everything running smoothly and securely.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 4),
            Button(
                type: ButtonType.secondary,
                onPressed: onPressSnapGuide,
                child: Text(
                  'Guide for Snap update',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}

class SnapUpdatedSuccesfully extends StatelessWidget {
  final VoidCallback onContinue;
  const SnapUpdatedSuccesfully({
    super.key,
    required this.textTheme,
    required this.onContinue,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/check.png', height: 100),
            const Gap(defaultPadding * 3),
            Text(
              'Your Silent Shard Snap has been successfully updated!',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding),
            Text(
              'Now make seamless transactions with enhanced security.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 4),
            Button(
                activeColor: Colors.red,
                onPressed: onContinue,
                child: Text(
                  'Continue',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}
