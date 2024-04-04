import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class SplitView extends StatefulWidget {
  const SplitView(
      {Key? key,
      required this.children,
      this.axis = MultiSplitView.defaultAxis,
      this.controller})
      : super(key: key);

  final List<Widget> children;
  final Axis axis;
  final MultiSplitViewController? controller;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    MultiSplitView mv = MultiSplitView(
      axis: widget.axis,
      controller: widget.controller,
      children: widget.children,
    );

    MultiSplitViewTheme theme = MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
              color: Colors.indigo[100]!,
              highlightedColor: Colors.indigo[900]!)),
      child: mv,
    );
    return Expanded(child: theme);
  }
}
