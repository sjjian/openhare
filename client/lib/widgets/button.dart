import 'package:client/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'const.dart';

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
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainer // icon button 鼠标悬浮的颜色
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

class LinkButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const LinkButton({Key? key, required this.text, this.onPressed})
      : super(key: key);

  @override
  State<LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color normalColor = Theme.of(context).colorScheme.primary;
    final Color hoverColor =
        Theme.of(context).colorScheme.primary.withOpacity(0.7);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 200,
          ),
          padding:
              const EdgeInsets.fromLTRB(kSpacingSmall, 0, kSpacingSmall, 0),
          // 只有当TextOverflow.ellipsis实际发生时才显示tooltip
          child: TooltipText(
            text: widget.text,
            style: TextStyle(
              color: _hovering ? hoverColor : normalColor,
              decoration: TextDecoration.underline,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
