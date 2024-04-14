// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';

class Cancel extends StatelessWidget {
  final String text;
  const Cancel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/cancel.png', height: 100),
        const Gap(defaultSpacing),
        Text(text, style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ],
    ));
  }
}
