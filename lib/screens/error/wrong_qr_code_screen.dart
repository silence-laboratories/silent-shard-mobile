import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class WrongQRCodeScreen extends StatelessWidget {
  final VoidCallback onTap;
  const WrongQRCodeScreen({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ErrorHandler(
      errorTitle: 'Oops! wrong QR detected',
      errorSubtitle: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: 'Please make sure you have visited ',
              style: textTheme.bodyMedium,
            ),
            TextSpan(
              text: 'snap.silencelaboratories.com',
              style: textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextSpan(
              text: ' on your desktop to scan the QR Code',
              style: textTheme.bodyMedium,
            )
          ],
        ),
      ),
      buttonTitle: 'Scan again',
      onBack: onTap,
      onPressBottomButton: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
