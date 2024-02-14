import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../constants.dart';
import '../components/button.dart';

class PairDialog extends StatefulWidget {
  final VoidCallback onFinish;

  const PairDialog({super.key, required this.onFinish});

  @override
  State<PairDialog> createState() => _PairDialogState();
}

class _PairDialogState extends State<PairDialog> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        children: [
          Text(
            'Pair with new account',
            style: textTheme.displayMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
              color: textPrimaryColor,
            ),
          )
        ],
      ),
      const Gap(defaultPadding),
      Text(
        'Please follow these steps in order to pair your mobile device with your browser',
        style: textTheme.bodySmall,
      ),
      const Gap(defaultPadding * 2),
      Stack(
        children: [
          AnimatedOpacity(
            opacity: currentPage == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: PairingStep(
                page: 0,
                info: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: 'Open ', style: textTheme.displaySmall),
                      TextSpan(text: 'snap.silencelaboratories.com', style: textTheme.displayMedium),
                      TextSpan(text: ' in your desktop browser.', style: textTheme.displaySmall),
                    ],
                  ),
                ),
                image: 'assets/images/pairing1.png'),
          ),
          AnimatedOpacity(
            opacity: currentPage == 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: PairingStep(
              page: 1,
              info: Text("Connect Silent Shard Snap with your MetaMask extension.", style: textTheme.displaySmall),
              image: 'assets/images/pairing2.png',
            ),
          ),
          AnimatedOpacity(
            opacity: currentPage == 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: PairingStep(
              page: 2,
              info: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'Scan the ', style: textTheme.displaySmall),
                    TextSpan(text: 'Purple QR Code', style: textTheme.displayMedium),
                    TextSpan(text: ' shown in the Silent Shard Snap.', style: textTheme.displaySmall),
                  ],
                ),
              ),
              image: 'assets/images/pairing3.png',
            ),
          ),
        ],
      ),
      PairingStepButton(
        showBack: currentPage != 0,
        onBack: () {
          setState(() {
            if (currentPage != 0) currentPage--;
          });
        },
        onNext: () {
          setState(() {
            if (currentPage != 2) currentPage++;
          });
        },
        showScanQR: currentPage == 2,
        onScanQR: widget.onFinish,
      ),
    ]);
  }
}

class PairingStepButton extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onScanQR;
  final bool showScanQR;
  final bool showBack;

  const PairingStepButton({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onScanQR,
    required this.showScanQR,
    required this.showBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          Button(
            onPressed: onBack,
            type: ButtonType.secondary,
            leftIcon: const Icon(
              Icons.arrow_back_ios,
              size: 14,
              color: Color(0xFFC5C8FF),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
              ),
            ),
          ),
        const Spacer(),
        if (showScanQR == false)
          Button(
            onPressed: onNext,
            rightIcon: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                color: textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),
        if (showScanQR == true)
          Button(
            onPressed: onScanQR,
            child: const Text(
              'Scan QR',
              style: TextStyle(
                color: textPrimaryColor,
                fontSize: 14,
              ),
            ),
          )
      ],
    );
  }
}

class PairingStep extends StatelessWidget {
  final int page;
  final Widget info;
  final String image;
  const PairingStep({
    super.key,
    required this.page,
    required this.info,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Step ${page + 1}:",
          style: const TextStyle(color: textPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Gap(defaultPadding * 2),
        info,
        const Gap(defaultPadding * 2),
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(image, width: MediaQuery.of(context).size.width - 100),
          const SizedBox(
            height: 4,
          ),
          Image.asset('assets/images/pairingRectangle1.png'),
          Image.asset('assets/images/pairingRectangle2.png')
        ]),
        const Gap(defaultPadding * 4),
      ]),
    );
  }
}
