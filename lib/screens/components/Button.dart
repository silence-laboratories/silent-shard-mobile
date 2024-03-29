// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';

enum ButtonType { primary, secondary }

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonType type;
  final EdgeInsetsGeometry? padding;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Widget? icon;
  final Text child;
  final Color? buttonColor;
  final double? fontSize;
  final bool isDisabled;

  const Button({
    super.key,
    this.onPressed,
    required this.child,
    this.padding,
    this.icon,
    this.type = ButtonType.primary,
    this.leftIcon,
    this.rightIcon,
    this.fontSize,
    this.buttonColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? EdgeInsets.all(defaultPadding * 1.5),
        disabledBackgroundColor: buttonColor ?? (type == ButtonType.secondary ? secondaryColor.withOpacity(0) : backgroundPrimaryColor),
        backgroundColor: buttonColor ?? (type == ButtonType.secondary ? secondaryColor.withOpacity(0) : backgroundPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: buttonColor ?? backgroundPrimaryColor, style: BorderStyle.solid),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leftIcon != null) ...[leftIcon!, Gap(defaultPadding)],
          child,
          if (rightIcon != null) ...[Gap(defaultPadding), rightIcon!]
        ],
      ),
    );
  }
}
