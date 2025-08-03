import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;
  const Loading(
      {super.key,
      this.size = 36,
      this.strokeWidth = 2,
      this.padding = const EdgeInsets.all(8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
      ),
    );
  }

  // big loading widget
  const Loading.big(
      {super.key,
      this.strokeWidth = 3,
      this.size = 48,
      this.padding = const EdgeInsets.all(8)});

  const Loading.small(
      {super.key,
      this.strokeWidth = 2,
      this.size = 20,
      this.padding = const EdgeInsets.all(2)});
}
