import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class CorruptedBackupFileErrorScreen extends StatelessWidget {
  const CorruptedBackupFileErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ErrorHandler(
      errorSubtitle: Text(
        'The backup up file might be wrong or else corrupted.',
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      onPressBottomButton: () {},
    );
  }
}
