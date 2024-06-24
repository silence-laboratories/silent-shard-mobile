import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class UpdateSnapGuide extends StatelessWidget {
  final VoidCallback onBack;
  final Image image;
  const UpdateSnapGuide({
    super.key,
    required this.textTheme,
    required this.onBack,
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
            Bullet(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'On your desktop browser, visit ',
                      style: textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: 'snap.silencelaboratories.com',
                      style: textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            Bullet(
                child: Text(
              'Connect your MetaMask wallet to the DApp',
              style: textTheme.bodyMedium,
            )),
            Bullet(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Once in the DApp home page, you will have an option to ',
                      style: textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: '"Update your Snap"',
                      style: textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextSpan(
                      text: ' to the latest version.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Bullet(
                child: Text(
              'Click on the Update button and follow the instructions.',
              style: textTheme.bodyMedium,
            )),
            const Gap(defaultSpacing * 4),
            Button(
                type: ButtonType.secondary,
                onPressed: onBack,
                child: Text(
                  'Go back',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}
