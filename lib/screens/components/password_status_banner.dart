import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';

enum PasswordBannerStatus { warn, alert, ready }

class PasswordStatusBanner extends StatelessWidget {
  const PasswordStatusBanner({super.key, required this.status});

  final PasswordBannerStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      PasswordBannerStatus.warn => const Icon(Icons.info, color: Color(0xfffdd147)),
      PasswordBannerStatus.alert => const Icon(Icons.error, color: Color(0xffF87171)),
      PasswordBannerStatus.ready => const Icon(Icons.check_circle, color: Color(0xff4ADE80)),
    };

    final text = switch (status) {
      PasswordBannerStatus.warn => const Text('Password not set on dApp', style: TextStyle(color: Color(0xFFFEE28A))),
      PasswordBannerStatus.alert => const Text('Password not set on dApp', style: TextStyle(color: Color(0xFFFECACA))),
      PasswordBannerStatus.ready => const Text('Password set on dApp', style: TextStyle(color: Color(0xFFBBF7D1)))
    };

    final border = switch (status) {
      PasswordBannerStatus.warn => Border.all(color: const Color(0xFF85680E), width: 1.0),
      PasswordBannerStatus.alert => Border.all(color: const Color(0xFF991B1B), width: 1.0),
      PasswordBannerStatus.ready => Border.all(color: const Color(0xFF166533), width: 1.0),
    };

    final bgColor = switch (status) {
      PasswordBannerStatus.warn => const Color.fromRGBO(253, 209, 71, 0.10),
      PasswordBannerStatus.alert => const Color.fromRGBO(248, 113, 113, 0.10),
      PasswordBannerStatus.ready => const Color.fromRGBO(74, 222, 128, 0.10),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
        border: border,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          icon,
          const Gap(defaultSpacing / 2),
          text,
          if (status == PasswordBannerStatus.alert) //
            ...[
            const Spacer(),
            const Icon(Icons.arrow_forward, color: Color(0xffF87171)),
          ]
        ],
      ),
    );
  }
}
