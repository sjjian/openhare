import 'package:flutter/material.dart';

class TooltipText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const TooltipText({Key? key, required this.text, this.style})
      : super(key: key);

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
                child: Text(text, style: textStyle),
              )
            : Text(text, style: textStyle);
      },
    );
  }
}
