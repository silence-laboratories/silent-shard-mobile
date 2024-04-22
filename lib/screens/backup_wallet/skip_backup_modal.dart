import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';

class BackupSkipWarning extends StatefulWidget {
  final VoidCallback onContinue;
  const BackupSkipWarning({super.key, required this.onContinue});

  @override
  State<BackupSkipWarning> createState() => _BackupSkipWarningState();
}

enum CheckBoxState { checked, unchecked }

class _BackupSkipWarningState extends State<BackupSkipWarning> {
  CheckBoxState _checkboxState = CheckBoxState.unchecked;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: defaultSpacing * 2, right: defaultSpacing * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Are you sure?",
            style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(defaultSpacing * 2),
          Center(
            child: Image.asset(
              'assets/images/warningYellow.png',
              height: 100,
            ),
          ),
          const Gap(defaultSpacing * 2),
          Text(
            'Your wallet backup file is crucial for restoring your funds in case any of your phone or laptop device is lost or reset.',
            style: textTheme.bodyMedium,
          ),
          const Gap(defaultSpacing * 2),
          const Divider(),
          Row(
            children: [
              Checkbox(
                value: _checkboxState == CheckBoxState.checked ? true : false,
                onChanged: (value) {
                  setState(() {
                    _checkboxState = (value ?? false) ? CheckBoxState.checked : CheckBoxState.unchecked;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'I understand the risk and agree to continue',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Gap(defaultSpacing),
          Button(
              type: ButtonType.primary,
              buttonColor: primaryColor.withOpacity(_checkboxState == CheckBoxState.unchecked ? 0.5 : 1),
              onPressed: () {
                _checkboxState == CheckBoxState.unchecked ? null : widget.onContinue();
              },
              isDisabled: _checkboxState == CheckBoxState.unchecked,
              child: Text('Continue', style: textTheme.displayMedium))
        ]),
      ),
    );
  }
}
