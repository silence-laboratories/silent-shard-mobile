import 'package:flutter/material.dart';

class Popup extends StatefulWidget {
  const Popup({
    required this.child,
    required this.follower,
    required this.controller,
    this.offset = Offset.zero,
    this.followerAnchor = Alignment.topCenter,
    this.targetAnchor = Alignment.bottomCenter,
    super.key,
  });
  final Widget child;
  final Widget follower;
  final OverlayPortalController controller;
  final Alignment followerAnchor;
  final Alignment targetAnchor;
  final Offset offset;

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
          controller: widget.controller,
          child: widget.child,
          overlayChildBuilder: (BuildContext context) {
            return Align(
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                followerAnchor: widget.followerAnchor,
                targetAnchor: widget.targetAnchor,
                offset: widget.offset,
                child: widget.follower,
              ),
            );
          }),
    );
  }
}
