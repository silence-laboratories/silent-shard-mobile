import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class AppUpdate extends StatelessWidget {
  final VoidCallback onAppUpdate;
  final Image image;
  const AppUpdate({
    super.key,
    required this.textTheme,
    required this.onAppUpdate,
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
      content: Wrap(children: [
        Stack(
          children: [
            Column(
              children: [
                image,
                const Gap(defaultSpacing * 3),
                Text(
                  'It’s time for a power-up ',
                  style: textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const Gap(defaultSpacing * 2.5),
                Text(
                  'Your Silent Shard app needs an immediate update to keep everything running smoothly and securely. ',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(defaultSpacing * 4),
                Button(
                  onPressed: onAppUpdate,
                  child: Text('Update now', style: textTheme.displayMedium),
                ),
              ],
            )
          ],
        ),
      ]),
    );
  }
}
