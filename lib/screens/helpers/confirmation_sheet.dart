import 'package:flutter/material.dart';
import 'menu_item.dart';

typedef ConfirmationCallback = void Function(bool);

class ConfirmationSheet extends StatelessWidget {
  final String message;
  final String yesTitle;
  final String noTitle;
  final ConfirmationCallback? onTap;

  const ConfirmationSheet({
    super.key,
    required this.message,
    this.yesTitle = 'Yes',
    this.noTitle = 'No',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: Color(0xFFE43636), fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 20),
          MenuItem(
            title: yesTitle,
            onTap: () => onTap?.call(true),
          ),
          MenuItem(
            title: noTitle,
            onTap: () => onTap?.call(false),
          ),
        ],
      ),
    );
  }
}
