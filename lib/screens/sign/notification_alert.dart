// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/padded_container.dart';

class NotificationAlertDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  const NotificationAlertDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      insetPadding: const EdgeInsets.all(defaultSpacing * 1.5),
      content: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Gap(defaultSpacing * 1.5),
          Text("Grant permission", style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(defaultSpacing),
          Center(child: Lottie.asset('assets/lottie/NotificationPermissionAndroid.json')),
          const Gap(defaultSpacing),
          Row(
            children: [
              const PaddedContainer(
                color: Color(0xFF343A46),
                child: Icon(Icons.notifications),
              ),
              const Gap(defaultSpacing),
              Text(
                "Notifications",
                style: textTheme.displayMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(defaultSpacing),
                decoration: BoxDecoration(
                  color: const Color(0xFF85680E).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF85680E),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  Icon(
                    Icons.error,
                    color: warningColor,
                    size: 16,
                  ),
                  Gap(defaultSpacing / 2),
                  Text(
                    'Mandatory',
                    style: TextStyle(fontSize: 12, color: warningColor),
                  ),
                ]),
              )
            ],
          ),
          const Gap(defaultSpacing * 2),
          Text(
            'Notifications in the silent shard app are crucial for timely transaction approval alerts.',
            style: textTheme.bodyMedium,
          ),
          if (Platform.isIOS) ...[
            const Gap(defaultSpacing * 2),
            const Divider(),
            const Gap(defaultSpacing * 2),
            Row(
              children: [
                PaddedContainer(
                  color: const Color(0xFF343A46),
                  child: Image.asset(
                    'assets/images/faceIDIcon.png',
                    height: 26,
                  ),
                ),
                const Gap(defaultSpacing),
                Text(
                  "Device Biometrics",
                  style: textTheme.displayMedium,
                )
              ],
            ),
            const Gap(defaultSpacing * 2),
            Text(
              'Unlock Silent Shard app by using your Device Biometrics (Face ID/ Fingerprint).',
              style: textTheme.bodyMedium,
            ),
          ],
          const Gap(defaultSpacing * 3),
          Button(
            onPressed: onAllow,
            child: Text('Allow', style: textTheme.displaySmall),
          ),
          const Gap(defaultSpacing * 2),
          Center(
            child: TextButton(
              onPressed: onDeny,
              child: Text(
                "Not now",
                style: textTheme.headlineMedium,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
