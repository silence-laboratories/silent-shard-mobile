// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/extensions/string_extension.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/padded_container.dart';

class MultiWalletMismatchScreen extends StatelessWidget {
  final VoidCallback onContinue;
  // final VoidCallback onBack;
  final String oldWalletId;
  final String oldWalletIcon;
  final String newWalletId;
  final String newWalletIcon;
  const MultiWalletMismatchScreen(
      {super.key,
      required this.onContinue,
      required this.oldWalletId,
      required this.oldWalletIcon,
      required this.newWalletId,
      required this.newWalletIcon});

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
                                'Oops! we noticed a mismatch!',
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(defaultSpacing * 3),
                              RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Looks like you are trying to recover a ',
                                        style: textTheme.bodyMedium,
                                      ),
                                      TextSpan(
                                        text: oldWalletId.capitalize(),
                                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' wallet’s backup into a ',
                                        style: textTheme.bodyMedium,
                                      ),
                                      TextSpan(
                                        text: newWalletId.capitalize(),
                                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' wallet',
                                        style: textTheme.bodyMedium,
                                      ),
                                    ],
                                  )),
                              const Gap(defaultSpacing * 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PaddedContainer(
                                      child: Image.asset(
                                    oldWalletIcon,
                                    height: 36,
                                  )),
                                  Container(
                                      margin: EdgeInsets.symmetric(horizontal: defaultSpacing * 4),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFFF6F7F9),
                                      )),
                                  PaddedContainer(
                                      child: Image.asset(
                                    newWalletIcon,
                                    height: 36,
                                  )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Color(0xFF991B1B),
                      //     ),
                      //     borderRadius: BorderRadius.circular(10),
                      //     color: Color(0xFFF87171).withOpacity(0.1),
                      //   ),
                      //   padding: EdgeInsets.all(defaultSpacing * 1.5),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Image.asset("assets/images/information-circle_light.png", height: 18, color: Color(0xFFF87171)),
                      //       Gap(defaultSpacing),
                      //       Flexible(
                      //         child: Text(
                      //           'Restoring the selected account will replace the existing one on your browser',
                      //           style: textTheme.bodySmall?.copyWith(
                      //             color: Color(0xFFFECACA),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Gap(defaultSpacing * 2),
                      // Button(
                      //   onPressed: () {
                      //     Navigator.of(context).pop();
                      //     onBack();
                      //   },
                      //   type: ButtonType.secondary,
                      //   child: Text(
                      //     'Go back',
                      //     style: textTheme.displaySmall?.copyWith(color: primaryColor, height: 2),
                      //   ),
                      // ),
                      Gap(defaultSpacing * 2),
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinue();
                        },
                        child: Text(
                          'Back to',
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
