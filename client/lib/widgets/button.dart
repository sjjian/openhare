import 'package:client/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'const.dart';

class RectangleIconButton extends StatefulWidget {
  final String? tooltip;
  final IconData icon;
  final double size;
  final double iconSize;
  final double padding;

  /// 不同的icon 存在视觉对齐与实际对齐不一样，因此加一个偏移量来调整
  final double verticalOffset;
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
      required this.padding,
      this.verticalOffset = 0,
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
    this.verticalOffset = 0,
  })  : size = kIconButtonSizeMedium,
        iconSize = kIconSizeMedium,
        padding = 4,
        super(key: key);

  const RectangleIconButton.small({
    Key? key,
    this.tooltip,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.verticalOffset = 0,
  })  : size = kIconButtonSizeSmall,
        iconSize = kIconSizeSmall,
        padding = 2,
        super(key: key);

  const RectangleIconButton.tiny({
    Key? key,
    this.tooltip,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.verticalOffset = 0,
  })  : size = kIconButtonSizeTiny,
        iconSize = kIconSizeTiny,
        padding = 2,
        super(key: key);

  @override
  State<RectangleIconButton> createState() => _RectangleIconButtonState();
}

class _RectangleIconButtonState extends State<RectangleIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
        cursor: widget.onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (value) {
          if (widget.onPressed != null && !_isHovering) {
            setState(() {
              _isHovering = true;
            });
          }
        },
        onExit: (value) {
          if (widget.onPressed != null && _isHovering) {
            setState(() {
              _isHovering = false;
            });
          }
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.padding,
              right: widget.padding,
              top: widget.padding + widget.verticalOffset,
              bottom: widget.padding - widget.verticalOffset,
            ),
            child: Container(
              width: widget.size - widget.padding * 2,
              height: widget.size - widget.padding * 2,
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
                size: widget.iconSize,
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
  final double? maxWidth;

  const LinkButton(
      {Key? key, required this.text, this.onPressed, this.maxWidth})
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
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth ?? 200,
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
