import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';

class PaddedContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const PaddedContainer({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color ?? secondaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
