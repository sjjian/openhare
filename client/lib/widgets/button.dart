import 'package:client/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'const.dart';

class RectangleIconButton extends StatefulWidget {
  final String? tooltip;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? hoverBackgroundColor;
  final VoidCallback? onPressed;

  const RectangleIconButton(
      {Key? key,
      this.tooltip,
      required this.icon,
      this.onPressed,
      required this.size,
      required this.iconSize,
      this.iconColor,
      this.backgroundColor,
      this.hoverBackgroundColor})
      : super(key: key);

  const RectangleIconButton.medium({
    Key? key,
    this.tooltip,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
  })  : size = kIconButtonSizeMedium,
        iconSize = kIconSizeMedium,
        super(key: key);

  const RectangleIconButton.small(
      {Key? key,
      this.tooltip,
      required this.icon,
      this.onPressed,
      this.iconColor,
      this.backgroundColor,
      this.hoverBackgroundColor})
      : size = kIconButtonSizeSmall,
        iconSize = kIconSizeSmall,
        super(key: key);

  const RectangleIconButton.tiny(
      {Key? key,
      this.tooltip,
      required this.icon,
      this.onPressed,
      this.iconColor,
      this.backgroundColor,
      this.hoverBackgroundColor})
      : size = kIconButtonSizeTiny,
        iconSize = kIconSizeTiny,
        super(key: key);

  @override
  State<RectangleIconButton> createState() => _RectangleIconButtonState();
}

class _RectangleIconButtonState extends State<RectangleIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
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
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: widget.size - 4,
              height: widget.size - 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.2),
                color: _isHovering
                    ? widget.hoverBackgroundColor ??
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer // icon button 鼠标悬浮的颜色
                    : widget.backgroundColor, // icon button 背景色
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize - 4,
              ),
            ),
          ),
        ));

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
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
