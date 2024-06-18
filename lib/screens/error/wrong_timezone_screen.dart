// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongTimezoneScreen extends StatelessWidget {
  final VoidCallback onPress;
  final VoidCallback onBack;
  const WrongTimezoneScreen({super.key, required this.onPress, required this.onBack});

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
              const Gap(defaultSpacing),
              Image.asset(
                'assets/images/time_setting.png',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              const Gap(defaultSpacing * 3),
              RichText(
                  text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'If the issue persists please reach out to ', style: textTheme.displaySmall),
                  TextSpan(text: 'snap@silencelaboratories.com', style: textTheme.displaySmall?.copyWith(color: primaryColor)),
                  TextSpan(text: '. We will get back to you within 8hrs.', style: textTheme.displaySmall),
                ],
              )),
            ],
          ),
        ),
      ),
      buttonTitle: 'Go to settings',
      onBack: onBack,
      onPressBottomButton: () {
        Navigator.of(context).pop();
        onPress();
      },
    );
  }
}
