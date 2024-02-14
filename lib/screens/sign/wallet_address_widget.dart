import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silentshard/screens/components/copy_button.dart';

class WalletAddressWidget extends StatelessWidget {
  final String title;
  final String displayText;
  final String copyText;
  final CrossAxisAlignment crossAxisAlignment;
  const WalletAddressWidget({
    super.key,
    required this.title,
    required this.displayText,
    required this.copyText,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Flexible(
      flex: 2,
      child: Column(crossAxisAlignment: crossAxisAlignment, children: [
        Text(
          title,
          style: textTheme.bodyMedium,
        ),
        Row(children: [
          Expanded(
            child: Text(
              displayText,
              // maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          CopyButton(
            followerAnchor: crossAxisAlignment == CrossAxisAlignment.end ? Alignment.topCenter : Alignment.topLeft,
            onCopy: () async {
              await Clipboard.setData(ClipboardData(text: copyText));
            },
          ),
        ])
      ]),
    );
  }
}
