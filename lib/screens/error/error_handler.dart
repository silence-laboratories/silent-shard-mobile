import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/Button.dart';

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
      canPop: true,
      onPopInvoked: (didPop) {
        if (onBack != null && didPop) onBack!();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
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
                    const Gap(defaultPadding * 2),
                    Text(
                      errorTitle ?? 'Something went wrong',
                      style: textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(defaultPadding),
                    if (errorSubtitle != null) errorSubtitle!,
                  ],
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
