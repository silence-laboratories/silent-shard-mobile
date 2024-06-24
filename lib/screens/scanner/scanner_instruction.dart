// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/screens/components/bullet.dart';

class ScannerInstruction extends StatelessWidget {
  const ScannerInstruction({super.key, required this.isOtherWalletInstructor, this.isRePairing = false});

  final bool isOtherWalletInstructor;
  final bool? isRePairing;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final listOfBullets = isOtherWalletInstructor
        ? <Bullet>[
            Bullet(
              child: Text("Head over to your favourite SilentShard-supported wallets (coming soon...) on your browser to desktop.",
                  style: textTheme.displaySmall),
            ),
            Bullet(
              child: Text("Follow the instructions to create a new distributed wallet.", style: textTheme.displaySmall),
            )
          ]
        : <Bullet>[
            Bullet(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'Open ', style: textTheme.displaySmall),
                    TextSpan(text: 'snap.silencelaboratories.com', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' in your desktop.', style: textTheme.displaySmall),
                  ],
                ),
              ),
            ),
            Bullet(
              child: Text("Connect Silent Shard Snap with your MetaMask extension.", style: textTheme.displaySmall),
            ),
            if (isRePairing == true)
              Bullet(
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: 'If account is already present:  press on the', style: textTheme.displaySmall),
                      const WidgetSpan(
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                        ),
                      ),
                      TextSpan(text: 'icon and click on ‘Recover account on phone’ and follow the instructions', style: textTheme.displaySmall),
                    ],
                  ),
                ),
              ),
          ];

    return Column(children: [
      ...listOfBullets,
      Bullet(
        child: RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'Scan QR code with ', style: textTheme.displaySmall),
              WidgetSpan(
                child: Image.asset('assets/icon/silentShardLogo.png', height: 20, width: 20),
              ),
              TextSpan(text: ' Silent Shard', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              TextSpan(text: ' logo and connect this device.', style: textTheme.displaySmall),
            ],
          ),
        ),
      ),
    ]);
  }
}
