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
  final Widget? bodyWidget;
  final VoidCallback? onPressBottomButton;
  final VoidCallback? onBack;

  const ErrorHandler({
    super.key,
    this.image,
    this.errorTitle,
    this.errorSubtitle,
    this.buttonTitle,
    this.bodyWidget,
    this.bottomWidget,
    this.onPressBottomButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (onBack != null && didPop) onBack!();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0,
          ),
          backgroundColor: Colors.black,
          body: Container(
            padding: const EdgeInsets.only(left: defaultPadding * 1.5, right: defaultPadding * 1.5, bottom: defaultPadding * 1.5),
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        image ??
                            Image.asset(
                              'assets/images/spill.png',
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                        const Gap(defaultPadding * 2),
                        Text(
                          errorTitle ?? 'Something went wrong',
                          style: textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (errorSubtitle != null) errorSubtitle!,
                        if (bodyWidget != null) bodyWidget!,
                      ],
                    ),
                  ),
                ),
              ),
              if (bottomWidget != null) bottomWidget!,
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
