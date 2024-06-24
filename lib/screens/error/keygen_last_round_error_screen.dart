// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class KeygenLastRoundErrorScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const KeygenLastRoundErrorScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.all(defaultSpacing * 1.5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(defaultSpacing * 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/accountMismatch.png',
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'Uh oh! Account creation failed on your app',
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Text(
                                'Don’t worry, this wasn’t your lucky address anyway. Please try again.',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              Column(
                                children: [
                                  Bullet(
                                      child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Delete the account on the DApp by clicking on the “Delete Account” button from the wallet menu options - ',
                                          style: textTheme.bodyMedium,
                                        ),
                                        const WidgetSpan(
                                          child: CircleAvatar(
                                            backgroundColor: secondaryColor,
                                            radius: 8,
                                            child: Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                              size: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Bullet(
                                      child: Text(
                                    'Approve the Deletion of account.',
                                    style: textTheme.bodyMedium,
                                  )),
                                  Bullet(
                                      child: Text(
                                    'Get started with a new pairing on your DApp and Mobile app.',
                                    style: textTheme.bodyMedium,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(defaultSpacing * 2),
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinue();
                        },
                        child: Text(
                          'Back to Pairing',
                          style: textTheme.displaySmall?.copyWith(height: 2),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
