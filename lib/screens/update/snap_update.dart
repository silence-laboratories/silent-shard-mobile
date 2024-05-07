import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class SnapUpdate extends StatelessWidget {
  final VoidCallback onPressSnapGuide;
  final Image image;
  final TextTheme textTheme;
  const SnapUpdate({
    super.key,
    required this.textTheme,
    required this.onPressSnapGuide,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultPadding * 1.5),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image,
            const Gap(defaultPadding * 3),
            Text(
              'Seems like you are using an outdated Snap version',
              style: textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding),
            Text(
              'Your Silent Shard App is shiny new and can’t really comprehend what the old version of MetaMask Snap is saying.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 2),
            Text(
              'Update your Snap now to keep everything running smoothly and securely.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultPadding * 4),
            Button(
                type: ButtonType.secondary,
                onPressed: onPressSnapGuide,
                child: Text(
                  'Guide for Snap update',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}
