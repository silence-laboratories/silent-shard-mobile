import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class SnapAndAppUpdate extends StatelessWidget {
  final VoidCallback onAppUpdate;
  final VoidCallback onPressSnapGuide;
  final Image image;

  const SnapAndAppUpdate({
    super.key,
    required this.textTheme,
    required this.onAppUpdate,
    required this.onPressSnapGuide,
    required this.image,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      insetPadding: const EdgeInsets.all(defaultSpacing * 1.5),
      content: SingleChildScrollView(
        child: Column(
          children: [
            image,
            const Gap(defaultSpacing * 3),
            Text(
              'Updates are pending! ',
              style: textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultSpacing * 2.5),
            Text(
              'Your Silent Shard app and your MetaMask SNAP need an immediate update to keep everything running smoothly and securely. ',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultSpacing * 4),
            Button(
              type: ButtonType.secondary,
              onPressed: onPressSnapGuide,
              child: Text('Guide for Snap update', style: textTheme.displayMedium),
            ),
            const Gap(defaultSpacing * 2),
            Button(
              onPressed: onAppUpdate,
              child: Text('Update app now', style: textTheme.displayMedium),
            ),
          ],
        ),
      ),
    );
  }
}
