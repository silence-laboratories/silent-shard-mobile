import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final bool alert;

  const MenuItem({super.key, required this.title, this.onTap, this.alert = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: alert ? const Color(0xFFE43636) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
