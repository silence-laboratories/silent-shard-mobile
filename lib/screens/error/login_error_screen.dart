// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/error/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginErrorReasonData {
  String title;
  String solution;

  LoginErrorReasonData(this.title, this.solution);
}

class LoginErrorScreen extends StatelessWidget {
  final VoidCallback? onPressBottomButton;

  const LoginErrorScreen({super.key, this.onPressBottomButton});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorSubtitle: Text(
        'We’re not able to put a finger to this issue',
        style: textTheme.bodyMedium,
      ),
      bodyWidget: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Gap(defaultPadding * 2),
        Text('It could be due to:', style: textTheme.displayMedium),
        const Gap(defaultPadding),
        LoginErrorReason(
            loginErrorReasonData: LoginErrorReasonData(
                'Issue with you current Date & Time settings', 'Check your Date & Time Settings and restore it to your local timezone')),
        const Gap(defaultPadding * 2),
        LoginErrorReason(
            loginErrorReasonData: LoginErrorReasonData('Issue with your Google services:',
                'Please verify if there are any disruptions or maintenance ongoing with Google services that might be affecting your access or functionality.\n\nYou can visit Google’s status page or support forums for any reported issues.')),
        const Gap(defaultPadding * 2),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'If the issue persists please reach out to ',
                style: textTheme.displaySmall,
              ),
              TextSpan(
                text: 'snap@silencelaboratories.com',
                style: textTheme.headlineSmall?.copyWith(
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'snap@silencelaboratories.com',
                    );
                    launchUrl(emailLaunchUri);
                  },
              ),
              TextSpan(
                text: '. We will get back to you within 8hrs',
                style: textTheme.displaySmall,
              )
            ],
          ),
        ),
        const Gap(defaultPadding * 2),
      ]),
      onPressBottomButton: onPressBottomButton,
    );
  }
}

class LoginErrorReason extends StatelessWidget {
  final LoginErrorReasonData loginErrorReasonData;
  const LoginErrorReason({super.key, required this.loginErrorReasonData});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loginErrorReasonData.title,
          style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(defaultPadding),
        Text(
          '💡 Solution:',
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          loginErrorReasonData.solution,
          style: textTheme.displaySmall,
        ),
      ]),
    );
  }
}
