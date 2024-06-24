// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class ErrorHandler extends StatelessWidget {
  final Widget? image;
  final String? errorTitle;
  final Widget? errorSubtitle;
  final String? buttonTitle;
  final Widget? bottomWidget;
  final VoidCallback? onPressBottomButton;
  final VoidCallback? onBack;

  const ErrorHandler({
    super.key,
    this.image,
    this.errorTitle,
    this.errorSubtitle,
    this.buttonTitle,
    this.bottomWidget,
    this.onPressBottomButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: onBack != null,
      onPopInvoked: (didPop) {
        if (onBack != null && didPop) onBack!();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: onBack != null,
          ),
          backgroundColor: Colors.black,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 1.5),
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image ??
                        Image.asset(
                          'assets/images/spill.png',
                          width: MediaQuery.of(context).size.width / 2,
                        ),
                    const Gap(defaultSpacing * 2),
                    Text(
                      errorTitle ?? 'Something went wrong',
                      style: textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(defaultSpacing),
                    if (errorSubtitle != null) errorSubtitle!,
                  ],
                ),
              ),
              if (bottomWidget != null) ...[bottomWidget!, const Gap(defaultSpacing)],
              Button(
                  onPressed: onPressBottomButton,
                  child: Text(
                    buttonTitle ?? 'Try again',
                    style: textTheme.displaySmall,
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
