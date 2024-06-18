// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongTimezoneScreen extends StatelessWidget {
  final VoidCallback onGotoSettings;
  final VoidCallback onScanAgain;
  const WrongTimezoneScreen({super.key, required this.onGotoSettings, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorTitle: 'Oops! It looks like your Date & Time settings need a quick adjustment',
      errorSubtitle: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: 'Please click on the ', style: textTheme.displaySmall),
                      TextSpan(text: '“Go to settings” ', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'button and toggle on ', style: textTheme.displaySmall),
                      TextSpan(text: '“Set time Automatically” ', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'to readjust to your local timezone.', style: textTheme.displaySmall),
                    ],
                  )),
              const Gap(defaultSpacing * 4),
              Text(
                "It should look like this 👇🏻",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(defaultSpacing * 2),
              Image.asset(
                'assets/images/time_setting.png',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ],
          ),
        ),
      ),
      buttonTitle: 'Scan again',
      onPressBottomButton: () {
        onScanAgain();
      },
      bottomWidget: Column(children: [
        const Gap(defaultSpacing),
        Button(
            type: ButtonType.secondary,
            onPressed: () {
              onGotoSettings();
            },
            child: Text(
              'Go to settings',
              style: textTheme.displaySmall?.copyWith(color: primaryColor2),
            )),
      ]),
    );
  }
}
