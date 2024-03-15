// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class WalletMismatchScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const WalletMismatchScreen({super.key, required this.onContinue, required this.onBack});

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
                    padding: const EdgeInsets.all(defaultPadding * 1.5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(defaultPadding * 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/accountMismatch.png',
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                              const Gap(defaultPadding * 3),
                              Text(
                                'Oops! we noticed a mismatch!',
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultPadding),
                              Text(
                                'Looks like you are recovering an account different from your current Snap account.',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultPadding),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF991B1B),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFF87171).withOpacity(0.1),
                        ),
                        padding: EdgeInsets.all(defaultPadding * 1.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/images/information-circle_light.png", height: 18, color: Color(0xFFF87171)),
                            Gap(defaultPadding),
                            Flexible(
                              child: Text(
                                'Restoring the selected account will replace the existing one on your browser',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Color(0xFFFECACA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(defaultPadding * 2),
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onBack();
                        },
                        type: ButtonType.secondary,
                        child: Text(
                          'Go back',
                          style: textTheme.displaySmall?.copyWith(color: primaryColor, height: 2),
                        ),
                      ),
                      Gap(defaultPadding * 2),
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinue();
                        },
                        child: Text(
                          'Continue',
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
