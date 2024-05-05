import 'package:flutter/widgets.dart';
import 'package:silentshard/constants.dart';

class FadeInOut extends StatefulWidget {
  final Widget child;
  final bool visible;
  const FadeInOut({super.key, required this.child, required this.visible});

  @override
  State<FadeInOut> createState() => _FadeInOutState();
}

class _FadeInOutState extends State<FadeInOut> {
  bool delayVisible = false; //This gives fade out effect depending on visible value

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      setDelayVisible(true);
    }
  }

  void setDelayVisible(bool value) {
    setState(() {
      delayVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: fadeInOutDuration,
      curve: Curves.easeInOut,
      onEnd: () {
        if (!widget.visible) {
          setDelayVisible(false);
        } else {
          setDelayVisible(true);
        }
      },
      child: widget.visible || delayVisible ? widget.child : const SizedBox(),
    );
  }
}
