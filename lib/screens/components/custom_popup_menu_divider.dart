// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';

class CustomPopupMenuDivider extends PopupMenuDivider {
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  const CustomPopupMenuDivider({
    super.height,
    super.key,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  }) : super();

  @override
  State<CustomPopupMenuDivider> createState() => _CustomPopupMenuDividerState();
}

class _CustomPopupMenuDividerState extends State<CustomPopupMenuDivider> {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: widget.height,
      thickness: widget.thickness,
      indent: widget.indent,
      endIndent: widget.endIndent,
      color: widget.color,
    );
  }
}
