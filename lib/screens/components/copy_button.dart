// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/popup.dart';

class CancelableFuture<T> {
  bool _cancelled = false;
  CancelableFuture({
    required Future<dynamic> future,
    required void Function(T) onComplete,
  }) {
    future.then((value) {
      if (!_cancelled) onComplete(value);
    });
  }
  void cancel() {
    _cancelled = true;
  }
}

class CopyButton extends StatefulWidget {
  final VoidCallback onCopy;
  final double? size;
  final Alignment? followerAnchor;

  const CopyButton({
    super.key,
    this.size,
    required this.onCopy,
    this.followerAnchor,
  });

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  CancelableFuture? _autoHidePopupOperation;
  final OverlayPortalController controller = OverlayPortalController();
  @override
  Widget build(BuildContext context) {
    return Popup(
      follower: _CopyOverlay(controller.hide),
      followerAnchor: widget.followerAnchor ?? Alignment.topLeft,
      targetAnchor: Alignment.bottomLeft,
      controller: controller,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultPadding),
        onTap: () {
          if (_autoHidePopupOperation is CancelableFuture<void>) {
            _autoHidePopupOperation?.cancel();
          }
          setState(() {
            _autoHidePopupOperation = CancelableFuture<void>(
              future: Future.delayed(const Duration(seconds: 4)),
              onComplete: (result) {
                controller.hide();
              },
            );
          });

          controller.show();
          widget.onCopy();
        },
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Image.asset(
            'assets/images/copyLight.png',
            height: widget.size ?? 20,
          ),
        ),
      ),
    );
  }
}

class _CopyOverlay extends StatelessWidget {
  const _CopyOverlay(this.hide);

  final VoidCallback hide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: secondaryColor),
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text('Copied!'),
    );
  }
}
