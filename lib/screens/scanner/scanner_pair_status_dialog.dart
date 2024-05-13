// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/components/check.dart';
import 'package:silentshard/screens/components/loader.dart';

class ScannerPairStatusDialog extends StatelessWidget {
  const ScannerPairStatusDialog({
    super.key,
    required this.isNotSucceed,
    required this.walletName,
  });

  final bool isNotSucceed;
  final String walletName;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedOpacity(
        opacity: !isNotSucceed ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: const Wrap(children: [
          Check(text: 'Successfully paired!'),
        ]),
      ),
      AnimatedOpacity(
        opacity: isNotSucceed ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: Wrap(children: [
          Loader(text: 'Pairing with $walletName...'),
        ]),
      ),
    ]);
  }
}
