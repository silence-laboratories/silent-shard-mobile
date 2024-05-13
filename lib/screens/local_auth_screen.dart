// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/services/local_auth_service.dart';

class LocalAuthScreen extends StatefulWidget {
  final LocalAuth localAuth;
  const LocalAuthScreen({
    super.key,
    required this.localAuth,
  });

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  onInit() async {
    await widget.localAuth.authenticate();
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
        child: Container(
      padding: const EdgeInsets.all(defaultSpacing * 4),
      child: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Image.asset(
                  'assets/images/lockClosed.png',
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ),
              const Gap(defaultSpacing * 2),
              Text(
                'Silent Shard is locked!',
                style: textTheme.displayLarge,
              ),
              Text(
                'Unlock with your Device Biometrics (Face ID/ Fingerprint/ PIN) to open Silent Shard',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          const Gap(defaultSpacing * 2),
          Button(
              onPressed: () async {
                final response = await widget.localAuth.authenticate();
                FirebaseCrashlytics.instance.log('Local auth ${response ? 'success' : 'failed'}');
              },
              child: Text(
                'Unlock',
                style: textTheme.displaySmall,
              ))
        ]),
      ),
    ));
  }
}
