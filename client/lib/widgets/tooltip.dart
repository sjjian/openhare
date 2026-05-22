import 'package:flutter/material.dart';

String tooltipWithShortcutDisplay(String description, String shortcutDisplay) {
  return '$description ($shortcutDisplay)';
}

class TooltipText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TooltipText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style != null
        ? style!.copyWith(overflow: TextOverflow.ellipsis)
        : const TextStyle(overflow: TextOverflow.ellipsis);

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: textStyle,
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        return isOverflowing
            ? Tooltip(
                message: text,
                child: Text(text, style: textStyle, maxLines: 1),
              )
            : Text(text, style: textStyle, maxLines: 1);
      },
    );
  }
}
