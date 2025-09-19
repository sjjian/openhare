import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double paddingSize;
  const Loading({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.paddingSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size - paddingSize * 2,
          height: size - paddingSize * 2,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }

  const Loading.large({super.key})
      : size = kIconButtonSizeLarge,
        strokeWidth = 2.5,
        paddingSize = (kIconButtonSizeLarge - kIconSizeLarge) / 2 + 4;

  const Loading.medium({super.key})
      : strokeWidth = 2,
        size = kIconButtonSizeMedium,
        paddingSize = (kIconButtonSizeMedium - kIconSizeMedium) / 2 + 2;

  const Loading.small({super.key})
      : strokeWidth = 1.5,
        size = kIconButtonSizeSmall,
        paddingSize = (kIconButtonSizeSmall - kIconSizeSmall) / 2;
}
