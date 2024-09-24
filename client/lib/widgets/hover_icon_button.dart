import 'package:flutter/material.dart';

class HoverIconButton extends StatefulWidget {
  final GestureTapCallback? onTap;
  final IconData? icon;

  const HoverIconButton({Key? key, this.onTap, this.icon}) : super(key: key);

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool isEnter = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isEnter = true;
        });
      },
      onExit: (_) {
        setState(() {
          isEnter = false;
        });
      },
      child: GestureDetector(
        onTap: () => widget.onTap,
        child: Container(
          width: 36,

          // color: Colors.blueGrey,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              widget.icon,
              size: isEnter ? 36 : 32,
            ),
          ),
        ),
      ),
    );
  }
}
