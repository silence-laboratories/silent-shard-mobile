// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/services/app_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onSkip;
  const OnboardingScreen({super.key, this.onSkip});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Gap(defaultSpacing * 2),
        Expanded(
          child: Stack(children: [
            Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: defaultSpacing),
              child: Text(
                'Silent Shard',
                style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor1),
              ),
            ),
            SizedBox.expand(
              child: Center(
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Lottie.asset('assets/lottie/OnboardingPurple.json', fit: BoxFit.cover),
                ),
              ),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Protect your wallet with a Two Factor Authenticator like experience", style: textTheme.displayLarge),
            const Gap(defaultSpacing),
            Text(
              "Powered by cutting edge MPC technology from Silence Laboratories",
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultSpacing * 3),
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
                    analyticManager.trackAppStart();
                    Provider.of<AppPreferences>(context, listen: false).setIsOnboardingCompleted(true);
                    FirebaseCrashlytics.instance.log("Onboarding done");
                  },
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(
                      "Get started",
                      style: textTheme.headlineSmall,
                    ),
                    const Gap(defaultSpacing / 2),
                    const Icon(
                      Icons.arrow_forward,
                      color: primaryColor,
                      size: 20,
                    ),
                  ]),
                ),
                const Gap(defaultSpacing),
              ],
            ),
          ]),
        ),
        const Gap(defaultSpacing * 2),
      ]),
    );
  }
}
