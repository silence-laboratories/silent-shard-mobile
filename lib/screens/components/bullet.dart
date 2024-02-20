// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';

class Bullet extends StatelessWidget {
  final Widget child;
  const Bullet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(defaultPadding),
        Text(
          "•",
          style: textTheme.displayMedium,
        ),
        const Gap(defaultPadding),
        Expanded(child: child),
      ],
    );
  }
}
