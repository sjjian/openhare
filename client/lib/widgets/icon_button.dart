import 'package:flutter/material.dart';

class RectangleIconButton extends StatefulWidget {
  final IconData icon;
  final double? size;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? hoverBackgroundColor;
  final VoidCallback? onPressed;

  const RectangleIconButton(
      {Key? key,
      required this.icon,
      this.onPressed,
      this.size = 36,
      this.iconSize = 24,
      this.iconColor,
      this.backgroundColor,
      this.hoverBackgroundColor})
      : super(key: key);

  @override
  State<RectangleIconButton> createState() => _RectangleIconButtonState();
}

class _RectangleIconButtonState extends State<RectangleIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // 需要矩形的鼠标点击鼠标悬浮效果
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (value) {
          if (!_isHovering) {
            setState(() {
              _isHovering = true;
            });
          }
        },
        onExit: (value) {
          if (_isHovering) {
            setState(() {
              _isHovering = false;
            });
          }
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _isHovering
                  ? widget.hoverBackgroundColor ??
                      Theme.of(context).colorScheme.surfaceContainer // icon button 鼠标悬浮的颜色
                  : widget.backgroundColor, // icon button 背景色
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
          ),
        ));
  }
}
