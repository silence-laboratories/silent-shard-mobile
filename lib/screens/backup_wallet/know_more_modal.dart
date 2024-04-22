import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:silentshard/constants.dart';

class BackupKnowMoreModal extends StatelessWidget {
  const BackupKnowMoreModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Gap(defaultSpacing),
            Text(
              'Google Password Manager',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(defaultSpacing * 2),
            Center(
              child: Lottie.asset('assets/lottie/GPMAnimation.json'),
            ),
            const BackupKnowMoreFAQ(
              question: 'Why am I saving a password?',
              answer: "The Silent Shard App leverages the your Google Password Manager to store your email id and your backup file.",
            ),
            const Gap(defaultSpacing * 2),
            const BackupKnowMoreFAQ(
              question: 'What is Google Password Manager?',
              answer: "Google Password Manager is an android feature that securely saves passwords in your device storage.",
            ),
            const Gap(defaultSpacing * 2),
            const BackupKnowMoreFAQ(
              question: 'What happens if I click on “Never”?',
              answer:
                  "Your backup will not be saved to your google password manager. You can still export the backup file to your device storage or any other password managers.",
            ),
            const Gap(defaultSpacing * 6),
          ]),
        )
      ],
    );
  }
}

class BackupKnowMoreFAQ extends StatelessWidget {
  final String question;
  final String answer;
  const BackupKnowMoreFAQ({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        question,
        style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      const Gap(defaultSpacing),
      Text(
        answer,
        style: textTheme.bodySmall,
      ),
    ]);
  }
}
