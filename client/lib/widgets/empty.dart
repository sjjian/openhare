import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final String message;
  final Color? color;

  const EmptyPage({super.key, required this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.surfaceDim,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.surfaceDim),
            ),
          ],
        ),
      ),
    );
  }
}
