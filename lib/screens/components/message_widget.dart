import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../constants.dart';

enum MessageType {
  info,
  warning,
  error;

  Color get borderColor => switch (this) {
        MessageType.info => infoColor,
        MessageType.warning => warningColor,
        MessageType.error => criticalColor,
      };

  Color get backgroundColor => switch (this) {
        MessageType.info => infoBackgroundColor,
        MessageType.warning => warningBackgroundColor,
        MessageType.error => criticalBackgroundColor,
      };

  Color get contentColor => switch (this) {
        MessageType.info => textPrimaryColor,
        MessageType.warning => warningColor,
        MessageType.error => errorBackgroundColor,
      };
}

class MessageWidget extends StatelessWidget {
  final String text;
  final MessageType type;

  const MessageWidget(this.text, {super.key, this.type = MessageType.info});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        border: Border.all(color: type.borderColor),
        borderRadius: BorderRadius.circular(defaultPadding),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/information-circle_light.png",
            height: 16,
            color: type.contentColor,
          ),
          const Gap(defaultPadding),
          Expanded(
            child: Text(text, style: textTheme.bodyMedium?.copyWith(color: type.contentColor)),
          ),
        ],
      ),
    );
  }
}
