import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class SplitViewController extends MultiSplitViewController {
  SplitViewController(Area first, Area second)
      : super(areas: [
          first.copyWith(
            data: () => 1,
          ),
          second.copyWith(
            data: () => 2,
          )
        ]);
}

class SplitView extends StatelessWidget {
  final SplitViewController controller;
  final Widget first;
  final Widget second;
  final Axis axis;

  const SplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      required this.first,
      required this.second,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MultiSplitView mv = MultiSplitView(
      axis: axis,
      controller: controller,
      builder: (context, area) {
        switch (area.data) {
          case 1:
            return first;
          case 2:
            return second;
          default:
            return const Spacer();
        }
      },
    );

    MultiSplitViewTheme theme = MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerPainter: DividerPainters.background(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
      child: mv,
    );
    return theme;
  }
}
