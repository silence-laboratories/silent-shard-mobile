// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/error/error_handler.dart';

class SomethingWentWrongScreen extends StatelessWidget {
  final VoidCallback onPress;
  const SomethingWentWrongScreen({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ErrorHandler(
      onBack: onPress,
      onPressBottomButton: () {
        Navigator.of(context).pop();
        onPress();
      },
    );
  }
}
