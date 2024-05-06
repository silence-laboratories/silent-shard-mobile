import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class SnapUpdatedSuccesfully extends StatelessWidget {
  final VoidCallback onContinue;
  const SnapUpdatedSuccesfully({
    super.key,
    required this.textTheme,
    required this.onContinue,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/check.png', height: 100),
            const Gap(defaultSpacing * 3),
            Text(
              'Your Silent Shard Snap has been successfully updated!',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Gap(defaultSpacing),
            Text(
              'Now make seamless transactions with enhanced security.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(defaultSpacing * 4),
            Button(
                activeColor: Colors.red,
                onPressed: onContinue,
                child: Text(
                  'Continue',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                ))
          ],
        ),
      ),
    );
  }
}
