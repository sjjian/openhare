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

class SplitView extends StatefulWidget {
  final Widget first;
  final Widget second;
  final Axis axis;
  final SplitViewController controller;

  const SplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      required this.first,
      required this.second,
      required this.controller})
      : super(key: key);

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    MultiSplitView mv = MultiSplitView(
      axis: widget.axis,
      controller: widget.controller,
      builder: (context, area) {
        switch (area.data) {
          case 1:
            return widget.first;
          case 2:
            return widget.second;
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
    return Expanded(child: theme);
  }
}
