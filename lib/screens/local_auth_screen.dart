// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/Button.dart';
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
      padding: const EdgeInsets.all(defaultPadding * 4),
      child: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                'assets/images/lockClosed.png',
                width: MediaQuery.of(context).size.width / 2,
              ),
              const Gap(defaultPadding * 2),
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
          Button(
              onPressed: () async {
                await widget.localAuth.authenticate();
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
